extends CanvasLayer

var hearts: Array[HeartGUI] = []
var maxHearts: int = 0

@onready var gameOverScreen: Control = $Control/GameOver
@onready var buttonContinue: Button = $Control/GameOver/VBoxContainer/ButtonContinue
@onready var buttonTitle: Button = $Control/GameOver/VBoxContainer/ButtonTitle
@onready var animationPlayer: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@export var audioFocus: AudioStream = preload("res://TitleScreen/audio/menu_focus.wav")
@export var audioSelect: AudioStream = preload("res://TitleScreen/audio/menu_select.wav")


func _ready() -> void:
	# Initialize hearts and setup UI
	_collect_hearts()
	_hide_all_hearts()
	_hide_game_over()

	buttonContinue.focus_entered.connect(_play_audio.bind(audioFocus))
	buttonContinue.pressed.connect(_on_continue_pressed)

	buttonTitle.focus_entered.connect(_play_audio.bind(audioFocus))
	buttonTitle.pressed.connect(_on_title_pressed)

	if Engine.has_singleton("LevelManager"):
		LevelManager.levelLoadStarted.connect(_hide_game_over)
	
	animationPlayer.animation_started.connect(_on_anim_started)
	animationPlayer.animation_finished.connect(_on_anim_finished)

func _on_anim_started(anim_name: String) -> void:
	# Handle animation start event
	print("Animation STARTED: ", anim_name)

func _on_anim_finished(anim_name: String) -> void:
	# Handle animation finish event
	print("Animation FINISHED: ", anim_name)

func _collect_hearts() -> void:
	# Collect all HeartGUI nodes into hearts array
	for node in $Control/GridContainer.get_children():
		if node is HeartGUI:
			hearts.append(node)

func _hide_all_hearts() -> void:
	# Hide all heart nodes
	for heart in hearts:
		heart.visible = false

func adjustHP(current_hp: int, max_hp: int) -> void:
	# Adjust hearts display based on current and max HP
	maxHearts = int(ceil(max_hp / 2.0))
	_show_relevant_hearts()
	_apply_hp_to_hearts(current_hp)

func _show_relevant_hearts() -> void:
	# Show hearts up to maxHearts, hide the rest
	for i in range(maxHearts):
		hearts[i].visible = true
	for i in range(maxHearts, hearts.size()):
		hearts[i].visible = false

func _apply_hp_to_hearts(current_hp: int) -> void:
	# Set heart values according to current HP
	var remaining_hp = current_hp
	for heart in hearts:
		if not heart.visible:
			continue

		var heart_value = 0
		if remaining_hp >= 2:
			heart_value = 2
			remaining_hp -= 2
		elif remaining_hp == 1:
			heart_value = 1
			remaining_hp -= 1

		heart.value = heart_value

func show_game_over_screen() -> void:
	# Show game over UI with animation
	gameOverScreen.visible = true
	gameOverScreen.mouse_filter = Control.MOUSE_FILTER_STOP

	animationPlayer.play("show_game_over")
	await animationPlayer.animation_finished

	buttonTitle.grab_focus()

func _hide_game_over() -> void:
	# Hide game over UI
	gameOverScreen.visible = false
	gameOverScreen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gameOverScreen.modulate = Color(1, 1, 1, 0)

func _on_continue_pressed() -> void:
	# Handle continue button press: reload current level and revive player
	LevelManager.debug_print_state()
	_play_audio(audioSelect)
	await get_tree().process_frame

	await _fade_to_black()
	_hide_game_over()
	var currentLevelPath = LevelManager.currentScenePath
	LevelManager.loadNewLevel(currentLevelPath, "", Vector2.ZERO)
	PlayerManager.player.revivePlayer()

func _on_title_pressed() -> void:
	# Handle title button press: load title screen
	_play_audio(audioSelect)
	await _fade_to_black()

	if Engine.has_singleton("LevelManager"):
		LevelManager.loadNewLevel("res://TitleScreen/title_screen.tscn", "", Vector2.ZERO)
	else:
		get_tree().change_scene_to_file("res://TitleScreen/title_screen.tscn")

func _fade_to_black() -> void:
	# Play fade to black animation
	print("fading to black")
	animationPlayer.play("fade_to_black")
	await animationPlayer.animation_finished

func _fade_to_black2() -> void:
	# Play alternate fade to black animation and revive player
	print("fading to black")
	animationPlayer.play("fade_to_black_2")
	await animationPlayer.animation_finished
	PlayerManager.player.revivePlayer()

func _play_audio(stream: AudioStream) -> void:
	# Play given audio stream
	audio.stream = stream
	audio.play()
