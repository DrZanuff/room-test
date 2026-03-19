extends Node

class_name PlayerInteractions

func handle_player_interaction(area: Area3D) -> void:
	if area.get_groups().size() > 0:
		var type = area.get_groups()[0]
		
		match type:
			"ICE_KEY":
				print("This an ice key")
