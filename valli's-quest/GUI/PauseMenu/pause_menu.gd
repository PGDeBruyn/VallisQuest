extends CanvasLayer

signal shown
signal hidden

@onready var _audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _buttons := {
	"save": $Control/VBoxContainer/ButtonSave,
	"load": $Control/VBoxContainer/ButtonLoad
}
@onready var _desc_label: Label = $Control/ItemDescription

func _ready() -> void:
	visible = false
	for key in _buttons.keys():
		_buttons[key].pressed.connect(func():
			_on_button_pressed(key)
		)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_menu()
		get_viewport().set_input_as_handled()

func _toggle_menu() -> void:
	if visible:
		_hide_menu()
	else:
		_show_menu()

func _show_menu() -> void:
	get_tree().paused = true
	visible = true
	emit_signal("shown")

func _hide_menu() -> void:
	get_tree().paused = false
	visible = false
	emit_signal("hidden")

func _on_button_pressed(name: String) -> void:
	if not visible:
		return
	match name:
		"save":
			SaveManager.save_game()
			_hide_menu()
		"load":
			await SaveManager.load_game()
			_hide_menu()

func update_item_description(new_text: String) -> void:
	_desc_label.text = new_text

func play_audio(audio_stream: AudioStream) -> void:
	if audio_stream:
		_audio_player.stream = audio_stream
		_audio_player.play()
