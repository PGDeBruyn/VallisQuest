extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var button_save: Button = $Control/VBoxContainer/ButtonSave
@onready var button_load: Button = $Control/VBoxContainer/ButtonLoad
@onready var item_description: Label = $Control/ItemDescription

var isPaused: bool = false

func _ready() -> void:
	hidePauseMenu()
	button_save.pressed.connect(_onSavePressed)
	button_load.pressed.connect(_onLoadPressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# Don't allow pause if dialogue or shop active
		if DialogueSystem.isActive:
			return
		if ShopMenu.isActive:
			return
		# Don't allow pause if player is dead
		if PlayerManager.player and PlayerManager.player.isDead:
			return
		
		if not isPaused:
			showPauseMenu()
		else:
			hidePauseMenu()
		get_viewport().set_input_as_handled()

func showPauseMenu() -> void:
	get_tree().paused = true
	visible = true
	isPaused = true
	shown.emit()

func hidePauseMenu() -> void:
	get_tree().paused = false
	visible = false
	isPaused = false
	hidden.emit()

func _onSavePressed() -> void:
	if not isPaused:
		return
	SaveManager.save_game()
	hidePauseMenu()

func _onLoadPressed() -> void:
	if not isPaused:
		return
	
	# Immediately hide menu so UI updates properly while loading
	hidePauseMenu()
	
	await SaveManager.load_game()
	await LevelManager.level_load_initiated

func updateItemDescription(newText: String) -> void:
	item_description.text = newText

func playAudio(audio: AudioStream) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
