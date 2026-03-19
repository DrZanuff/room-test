extends CSGCombiner3D

class_name IceDoor

@onready var _door_animation: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	GameManager.register_door(self)

func open_door() -> void:
	_door_animation.play("open")
