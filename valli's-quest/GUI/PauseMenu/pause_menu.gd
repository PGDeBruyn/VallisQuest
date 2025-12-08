extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var button_save: Button = $Control/VBoxContainer/ButtonSave
@onready var button_load: Button = $Control/VBoxContainer/ButtonLoad
@onready var item_description: Label = $Control/ItemDescription

var isPaused: bool = false

# Initialize pause menu and connect button signals
func _ready() -> void:
	hidePauseMenu()
	button_save.pressed.connect(_onSavePressed)
	button_load.pressed.connect(_onLoadPressed)

# Handle pause input, blocking pause if dialogue/shop active or player dead
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if DialogueSystem.isActive:
			return
		if ShopMenu.isActive:
			return
		if PlayerManager.player and PlayerManager.player.isDead:
			return
		
		if not isPaused:
			showPauseMenu()
		else:
			hidePauseMenu()
		get_viewport().set_input_as_handled()

# Show the pause menu and pause the game tree
func showPauseMenu() -> void:
	get_tree().paused = true
	visible = true
	isPaused = true
	shown.emit()

# Hide the pause menu and unpause the game tree
func hidePauseMenu() -> void:
	get_tree().paused = false
	visible = false
	isPaused = false
	hidden.emit()

# Save game data when save button pressed and pause menu is active
func _onSavePressed() -> void:
	if not isPaused:
		return
	SaveManager.save_game()
	hidePauseMenu()

# Load game data asynchronously when load button pressed and pause menu is active
func _onLoadPressed() -> void:
	if not isPaused:
		return
	
	hidePauseMenu()
	
	await SaveManager.load_game()
	await LevelManager.level_load_initiated

# Update the item description label in the pause menu UI
func updateItemDescription(newText: String) -> void:
	item_description.text = newText

# Play audio clip via the pause menu's audio player
func playAudio(audio: AudioStream) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
