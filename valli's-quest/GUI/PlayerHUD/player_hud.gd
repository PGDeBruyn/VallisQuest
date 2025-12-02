extends CanvasLayer

#
# ─── HEART SYSTEM ──────────────────────────────────────────────────────────────
#

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
	_collect_hearts()
	_hide_all_hearts()

	# Game Over UI setup
	_hide_game_over()

	buttonContinue.focus_entered.connect(_play_audio.bind(audioFocus))
	buttonContinue.pressed.connect(_on_continue_pressed)

	buttonTitle.focus_entered.connect(_play_audio.bind(audioFocus))
	buttonTitle.pressed.connect(_on_title_pressed)

	# optional, matches the tutorial
	if Engine.has_singleton("LevelManager"):
		LevelManager.levelLoadStarted.connect(_hide_game_over)
	
	animationPlayer.animation_started.connect(_on_anim_started)
	animationPlayer.animation_finished.connect(_on_anim_finished)

func _on_anim_started(anim_name: String) -> void:
	print("Animation STARTED: ", anim_name)

func _on_anim_finished(anim_name: String) -> void:
	print("Animation FINISHED: ", anim_name)


#
# ─── HEART SETUP ───────────────────────────────────────────────────────────────
#

func _collect_hearts() -> void:
	for node in $Control/GridContainer.get_children():
		if node is HeartGUI:
			hearts.append(node)

func _hide_all_hearts() -> void:
	for heart in hearts:
		heart.visible = false

func adjustHP(current_hp: int, max_hp: int) -> void:
	maxHearts = int(ceil(max_hp / 2.0))
	_show_relevant_hearts()
	_apply_hp_to_hearts(current_hp)


func _show_relevant_hearts() -> void:
	for i in range(maxHearts):
		hearts[i].visible = true
	for i in range(maxHearts, hearts.size()):
		hearts[i].visible = false


func _apply_hp_to_hearts(current_hp: int) -> void:
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

		#heart.set_value(heart_value)
		heart.value = heart_value




#
# ─── GAME OVER SCREEN ──────────────────────────────────────────────────────────
#

func show_game_over_screen() -> void:
	gameOverScreen.visible = true
	gameOverScreen.mouse_filter = Control.MOUSE_FILTER_STOP

	animationPlayer.play("show_game_over")
	await animationPlayer.animation_finished

	buttonTitle.grab_focus()


func _hide_game_over() -> void:
	gameOverScreen.visible = false
	gameOverScreen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gameOverScreen.modulate = Color(1, 1, 1, 0)



#
# ─── BUTTON CALLBACKS ──────────────────────────────────────────────────────────
#

func _on_continue_pressed() -> void:
	LevelManager.debug_print_state()
	_play_audio(audioSelect)
	#_hide_game_over()
	
	#print("Fade visibility before play:", $Control/GameOver/FadeToBlack.visible)
	#$Control/GameOver/FadeToBlack.visible = true
	await get_tree().process_frame
	#print("Fade visibility after forcing visible:", $Control/GameOver/FadeToBlack.visible)

	await _fade_to_black()
	_hide_game_over()
	var currentLevelPath = LevelManager.currentScenePath
	LevelManager.loadNewLevel(currentLevelPath, "", Vector2.ZERO)
	PlayerManager.player.revivePlayer()






func _on_title_pressed() -> void:
	_play_audio(audioSelect)
	await _fade_to_black()

	if Engine.has_singleton("LevelManager"):
		LevelManager.loadNewLevel("res://TitleScreen/title_screen.tscn", "", Vector2.ZERO)
	else:
		get_tree().change_scene_to_file("res://TitleScreen/title_screen.tscn")



#
# ─── ANIMATIONS ────────────────────────────────────────────────────────────────
#

func _fade_to_black() -> void:
	print("fading to black")
	animationPlayer.play("fade_to_black")
	await animationPlayer.animation_finished

func _fade_to_black2() -> void:
	print("fading to black")
	animationPlayer.play("fade_to_black_2")
	await animationPlayer.animation_finished
	PlayerManager.player.revivePlayer()

func _play_audio(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()
