extends Node3D

func _ready() -> void:
	GameUi.show_message(
		"You need to enter the Ice Dome to win the game." + "\n\n" +
		"Controls:" + "\n" +
		"WASD or Arrow Keys: Move the Player." + "\n" +
		"SPACE: Jump." + "\n" +
		"E: Interact with elements." + "\n" +
		"MOUSE: Rotate the camera." + "\n" +
		"Scroll Up and Down: Zoom Camera." + "\n" +
		"ESC: Unlock Mouse",
		func(): pass
	)
