extends Node2D

const START_LEVEL := "res://Levels/Area1/01.tscn"

@onready var buttonNew: Button = $CanvasLayer/Control/ButtonNew
@onready var buttonContinue: Button = $CanvasLayer/Control/ButtonContinue
@onready var audio_stream_player := $AudioStreamPlayer
@onready var camera_2d := $Camera2D

@export var music: AudioStream
@export var buttonFocusAudio: AudioStream
@export var buttonPressAudio: AudioStream


enum ScreenState { HIDDEN, READY, TRANSITIONING }
var current_state: ScreenState = ScreenState.HIDDEN


func _ready() -> void:
	# Title screen owns menu flow, not world.
	_prepare_environment()
	_setup_interactions()
	_apply_menu_state()
	current_state = ScreenState.READY
	
	if PlayerHud:
		PlayerHud._hide_game_over()


# -------------------------------------------------------------------
# CORE INITIALIZATION
# -------------------------------------------------------------------
func _prepare_environment() -> void:
	get_tree().paused = true

	PlayerManager.player.visible = false
	PlayerHud.visible = false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED

	AudioManager.playMusic(music)


# -------------------------------------------------------------------
# INPUT + SIGNAL HOOKUP
# -------------------------------------------------------------------
func _setup_interactions() -> void:
	# Button actions
	buttonNew.pressed.connect(_start_game)
	buttonContinue.pressed.connect(load_game)

	# UI sound behavior
	for b in [buttonNew, buttonContinue]:
		b.focus_entered.connect(func(): playAudio(buttonFocusAudio))

	# Connect to the correct LevelManager signal
	LevelManager.level_load_initiated.connect(exit_title_screen)


# -------------------------------------------------------------------
# MENU LOGIC (fresh)
# -------------------------------------------------------------------
func _apply_menu_state() -> void:
	# Title screen should always process input even when paused
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS

	var save_file: FileAccess = null
	save_file = SaveManager.get_save_file()

	var show_continue := save_file != null

	_update_button_visibility(buttonContinue, show_continue)
	buttonNew.grab_focus()


func _update_button_visibility(button: Button, visible: bool) -> void:
	button.visible = visible
	button.disabled = not visible


# -------------------------------------------------------------------
# GAME ACTIONS (same names, new behavior)
# -------------------------------------------------------------------
func _start_game() -> void:
	if current_state != ScreenState.READY:
		return

	current_state = ScreenState.TRANSITIONING
	playAudio(buttonPressAudio)

	# --- NEW GAME RESET LOGIC ---
	# Completely clear inventory so you NEVER retain items from a prior run
	var inv := PlayerManager.INVENTORY_DATA
	inv.slots.clear()
	inv.slots.resize(15)  # <-- replace with your actual slot count
	inv.emit_signal("inventory_changed")

	# Reset gems or other global stats if you use them
	if PlayerManager.has_method("setGemAmount"):
		PlayerManager.setGemAmount(0)

	# Load very first level
	LevelManager.loadNewLevel(START_LEVEL, "", Vector2.ZERO)



func load_game() -> void:
	if current_state != ScreenState.READY:
		return

	current_state = ScreenState.TRANSITIONING
	playAudio(buttonPressAudio)
	SaveManager.load_game()


func exit_title_screen() -> void:
	# World UI comes back alive only when leaving this screen
	PlayerManager.player.visible = true
	PlayerHud.visible = true
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS

	queue_free()


func playAudio(stream: AudioStream) -> void:
	audio_stream_player.stream = stream
	audio_stream_player.play()
