extends Node

class_name PlayerInteractions

var _current_interaction: String = ""

func handle_player_interaction(area: Area3D) -> void:
	if area.get_groups().size() > 0:
		var type = area.get_groups()[0]
		GameUi.show_interaction()
		_current_interaction = type
		
		match type:
			"ICE_DOME":
				GameUi.show_message(
					"You've completed the mystery and won the game!" + "\n" +
					"Thank you for Playing!" + "\n\n" +
					"Click in 'OK' to play again.",
					func():
						GameManager.reset_game()
						get_tree().reload_current_scene()
				)
			
			"BOTTOM_PIT":
				GameManager.reset_game()
				get_tree().reload_current_scene()

func handle_area_exited(area: Area3D) -> void:
	GameUi.hide_interaction()
	_current_interaction = ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and not _current_interaction.is_empty():
		match _current_interaction:
			"ICE_KEY":
				if GameManager.has_key():
					GameUi.show_message(
						"You already have the key. Go find the door!",
						func() : pass
					)
				else:
					GameUi.show_message(
						"This is an Ice Key... Maybe it can open an Ice Door...",
						func() :
							var parent = get_parent()
							if parent is Player:
								parent.got_key.emit()
					)
			
			"ICE_DOOR":
				if GameManager.is_door_open():
					GameUi.show_message(
						"The door is already open. You may enter the Ice Dome!",
						func(): pass
					)
					return
				
				if GameManager.has_key():
					GameUi.show_message(
						"You unlocked the Ice Door with the Ice Key!",
						func():
							GameManager.open_door()
							var parent = get_parent()
							if parent is Player:
								parent.shake_player_camera()
							
					)
				
				else:
					GameUi.show_message(
						"This is an Ice Door... Maybe and Ice Key in a Well could open it?",
						func(): pass
					)
			
