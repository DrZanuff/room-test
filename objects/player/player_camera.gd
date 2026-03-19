extends Marker3D

@onready var _camera: Camera3D = %Camera3D

@export var _zoom_step: float = 0.3
@export var _min_z: float = 0.8
@export var _max_z: float = 2.5
@export var _zoom_smooth_speed: float = 10.0

var _target_z: float = 0.0

func _ready() -> void:
	_target_z = clampf(_camera.position.z, _min_z, _max_z)
	_set_camera_z(_target_z)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		_move_camera_z(-_zoom_step)
	elif event.is_action_pressed("scroll_down"):
		_move_camera_z(_zoom_step)

func _process(delta: float) -> void:
	var current_z := _camera.position.z
	var t := clampf(_zoom_smooth_speed * delta, 0.0, 1.0)
	var next_z := lerpf(current_z, _target_z, t)
	_set_camera_z(next_z)

func _move_camera_z(delta_z: float) -> void:
	_target_z = clampf(_target_z + delta_z, _min_z, _max_z)

func _set_camera_z(z_value: float) -> void:
	var local_pos := _camera.position
	local_pos.z = z_value
	_camera.position = local_pos
