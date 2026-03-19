extends CSGCombiner3D

class_name IceDoor

@onready var _door_animation: AnimationPlayer = %AnimationPlayer

func open_door() -> void:
	_door_animation.play("open")
