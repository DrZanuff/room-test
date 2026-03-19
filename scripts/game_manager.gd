extends Node

var _player_has_key: bool = false

var _player: Player
var _door: IceDoor

func register_player(player: Player) -> void:
	_player = player
	player.got_key.connect(_get_key)

func register_door(door : IceDoor) -> void:
	_door = door

func _get_key() -> void:
	_player_has_key = true

func has_key() -> bool:
	return _player_has_key

func open_door() -> void:
	if not _door:
		print("No door registered!")
		return
	
	_door.open_door()
