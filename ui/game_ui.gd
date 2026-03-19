extends Control

@onready var _message_container: PanelContainer = %MessageContainer
@onready var _interaction_container: CenterContainer = %InteractionContainer
@onready var _message_label: Label = %MessageLabel
@onready var _confirmation_button: Button = %ConfirmationButton

var _call_back : Callable

func _ready() -> void:
	_interaction_container.hide()
	_message_container.hide()
	_confirmation_button.pressed.connect(_hide_message)
	
func _hide_message() -> void:
	_message_container.hide()
	if _call_back:
		_call_back.call()

func show_message(text: String, call_back: Callable) -> void:
	_message_label.text = text
	_call_back = call_back
	_message_container.show()

func show_interaction() -> void:
	_interaction_container.show()

func hide_interaction() -> void:
	_interaction_container.hide()
