extends Node2D

# Path to the first level scene to load on a new game start
const START_LEVEL := "res://Levels/Area1/01.tscn"

# Cached references to UI buttons and other nodes in the scene
@onready var buttonNew: Button = $CanvasLayer/Control/ButtonNew
@onready var buttonContinue: Button = $CanvasLayer/Control/ButtonContinue
@onready var audio_stream_player := $AudioStreamPlayer
@onready var camera_2d := $Camera2D

# Audio streams for music and UI sounds, exported to set in editor
@export var music: AudioStream
@export var buttonFocusAudio: AudioStream
@export var buttonPressAudio: AudioStream

# Enum to track the current state of the title screen
enum ScreenState { HIDDEN, READY, TRANSITIONING }
var current_state: ScreenState = ScreenState.HIDDEN


func _ready() -> void:
	# Setup the title screen environment and UI flow
	_prepare_environment()
	_setup_interactions()
	_apply_menu_state()
	current_state = ScreenState.READY
	
	# Hide the game over screen if it exists (from PlayerHud)
	if PlayerHud:
		PlayerHud._hide_game_over()


func _prepare_environment() -> void:
	# Pause the entire game tree (game world) while on the title screen
	get_tree().paused = true

	# Hide the player and HUD so they don't show on the title screen
	PlayerManager.player.visible = false
	PlayerHud.visible = false
	
	# Disable the pause menu processing as it is not needed here
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED

	# Start playing the title screen music
	AudioManager.playMusic(music)


func _setup_interactions() -> void:
	# Connect button press signals to their respective handlers
	buttonNew.pressed.connect(_start_game)
	buttonContinue.pressed.connect(load_game)

	# Connect focus_entered signals to play UI focus sound for buttons
	for b in [buttonNew, buttonContinue]:
		b.focus_entered.connect(func(): playAudio(buttonFocusAudio))

	# Listen for the LevelManager signal indicating level load start to close title screen
	LevelManager.level_load_initiated.connect(exit_title_screen)


func _apply_menu_state() -> void:
	# Ensure UI input is still processed even though the tree is paused
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS

	# Check if a save file exists to determine if Continue button should be shown
	var save_file: FileAccess = null
	save_file = SaveManager.get_save_file()
	var show_continue := save_file != null

	# Update the Continue button visibility accordingly
	_update_button_visibility(buttonContinue, show_continue)
	
	# Set initial focus on the New Game button
	buttonNew.grab_focus()


func _update_button_visibility(button: Button, visible: bool) -> void:
	# Show or hide the button and enable/disable interaction accordingly
	button.visible = visible
	button.disabled = not visible


func _start_game() -> void:
	# Only allow starting a new game if the title screen is ready
	if current_state != ScreenState.READY:
		return

	current_state = ScreenState.TRANSITIONING
	
	# Play the button press sound effect
	playAudio(buttonPressAudio)

	# Clear player's inventory completely so no items carry over
	var inv := PlayerManager.INVENTORY_DATA
	inv.slots.clear()
	inv.slots.resize(15)  # <-- Replace with your actual inventory slot count
	inv.emit_signal("inventory_changed")

	# Reset other global stats like gems if applicable
	if PlayerManager.has_method("setGemAmount"):
		PlayerManager.setGemAmount(0)

	# Load the very first level to start the game
	LevelManager.loadNewLevel(START_LEVEL, "", Vector2.ZERO)


func load_game() -> void:
	# Only allow loading a game if the title screen is ready
	if current_state != ScreenState.READY:
		return

	current_state = ScreenState.TRANSITIONING
	
	# Play the button press sound effect
	playAudio(buttonPressAudio)
	
	# Use the SaveManager to load the saved game state
	SaveManager.load_game()


func exit_title_screen() -> void:
	# Called when leaving the title screen and entering the world

	# Show player and HUD again
	PlayerManager.player.visible = true
	PlayerHud.visible = true
	
	# Enable pause menu processing again
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS

	# Remove the title screen from the scene tree
	queue_free()


func playAudio(stream: AudioStream) -> void:
	# Play a one-shot audio stream on the AudioStreamPlayer node
	audio_stream_player.stream = stream
	audio_stream_player.play()
