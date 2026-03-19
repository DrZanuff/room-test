extends RigidBody3D

class_name Player

enum PlayerState {
	IDLE,
	MOVE,
	JUMP
}

signal got_key

@onready var _camera_pivot: Marker3D = %CameraPivot

#Raycasts
@onready var _raycast1: RayCast3D = %RayCast1
@onready var _raycast2: RayCast3D = %RayCast2
@onready var _raycast3: RayCast3D = %RayCast3
@onready var _raycast4: RayCast3D = %RayCast4
@onready var _raycast_pivot: Marker3D = %RaycastPivot

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

@onready var _player_sensor: Area3D = %PlayerSensor

@onready var _player_interactions: PlayerInteractions = %PlayerInteractions

@export var _speed: float = 0.8
@export var _jump_strengh: float = 50.0
@export var _deceleration: float = 6.0
@export var _move_speed_threshold: float = 0.15

# Mouse sensitivity (horizontal rotation only).
@export var _mouse_sensitivity: float = 0.002

# How far the downward raycasts should check for ground.
@export var _ground_ray_length: float = 1.2

var _gravity: float:
	get:
		# Map to the built-in RigidBody3D gravity_scale.
		return gravity_scale
	set(value):
		# Normalize/clamp so negative values don't break physics.
		gravity_scale = maxf(0.0, value)

var _yaw: float = 0.0
var _is_jump_locked: bool = false
var _player_state: PlayerState = PlayerState.IDLE

func _ready() -> void:
	_player_sensor.area_entered.connect(_player_interactions.handle_player_interaction)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not _animation_player.animation_finished.is_connected(_on_animation_finished):
		_animation_player.animation_finished.connect(_on_animation_finished)

	# Ensure jump can emit `animation_finished` (looping jumps never finish).
	var jump_animation := _animation_player.get_animation("jump")
	if jump_animation:
		jump_animation.loop_mode = Animation.LOOP_NONE

	_set_state(PlayerState.IDLE)

	# Ensure the raycasts are active and point downward for "in floor" validation.
	for ray in [_raycast1, _raycast2, _raycast3, _raycast4]:
		ray.enabled = true
		# Prevent the raycasts from immediately hitting the player's own collider.
		ray.exclude_parent = true
		ray.target_position = Vector3(0.0, -_ground_ray_length, 0.0)
	# Apply the gravity normalization/clamp once at startup.
	_gravity = _gravity
	if jump_animation == null:
		push_warning("Missing 'jump' animation in AnimationPlayer.")

func _unhandled_input(event: InputEvent) -> void:
	_apply_mouse_look(event)

func _process(_delta: float) -> void:
	# Camera follows only position (X/Y/Z) and yaw, not the physics body's roll/pitch.
	var yaw_basis := Basis().rotated(Vector3.UP, _yaw)
	var player_global_origin = Transform3D(yaw_basis, global_transform.origin)
	_camera_pivot.global_transform = player_global_origin
	_raycast_pivot.global_transform = player_global_origin

func _physics_process(delta: float) -> void:
	var on_floor := _is_on_floor()

	# Jump (only if on the floor).
	if Input.is_action_just_pressed("jump") and on_floor and not _is_jump_locked:
		sleeping = false
		_is_jump_locked = true
		_set_state(PlayerState.JUMP)
		# In this setup, applying central impulse does not produce upward velocity.
		# Set jump takeoff velocity directly for consistent jumps.
		linear_velocity = Vector3(linear_velocity.x, _jump_strengh, linear_velocity.z)

	# Horizontal movement (XZ plane) driven by camera pivot orientation.
	var forward := -_camera_pivot.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := _camera_pivot.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()

	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("up"):
		input_dir += forward
	if Input.is_action_pressed("down"):
		input_dir -= forward
	if Input.is_action_pressed("left"):
		input_dir -= right
	if Input.is_action_pressed("right"):
		input_dir += right

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		# Use force so the Rigidbody3D integrates motion through physics.
		apply_central_force(input_dir * (_speed * mass))
	else:
		# Apply deceleration when there is no movement input on X/Z.
		var lv := linear_velocity
		var horizontal := Vector3(lv.x, 0.0, lv.z)
		horizontal = horizontal.move_toward(Vector3.ZERO, _deceleration * delta)
		linear_velocity = Vector3(horizontal.x, lv.y, horizontal.z)

	_update_animation_state()

func _is_on_floor() -> bool:
	for ray in [_raycast1, _raycast2, _raycast3, _raycast4]:
		ray.force_raycast_update()
		if ray.is_colliding():
			return true
	return false

func _input(event):
	_apply_mouse_look(event)

	# Toggle lock with ESC key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"jump":
		_is_jump_locked = false

func _update_animation_state() -> void:
	if _is_jump_locked:
		_set_state(PlayerState.JUMP)
		return

	var horizontal_speed := Vector2(linear_velocity.x, linear_velocity.z).length()
	if horizontal_speed > _move_speed_threshold:
		_set_state(PlayerState.MOVE)
	else:
		_set_state(PlayerState.IDLE)

func _set_state(new_state: PlayerState) -> void:
	if _player_state == new_state:
		return
	_player_state = new_state

	match _player_state:
		PlayerState.IDLE:
			_play_animation("idle")
		PlayerState.MOVE:
			_play_animation("move")
		PlayerState.JUMP:
			_play_animation("jump")

func _play_animation(animation_name: StringName) -> void:
	if _animation_player.current_animation != animation_name:
		_animation_player.play(animation_name)

func _apply_mouse_look(event: InputEvent) -> void:
	# Use _input for reliability; keep _unhandled_input as fallback.
	if event is InputEventMouseMotion:
		var mouse_delta_x: float = event.relative.x
		if mouse_delta_x != 0.0:
			_yaw += -mouse_delta_x * _mouse_sensitivity
