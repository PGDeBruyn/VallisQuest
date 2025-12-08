extends CanvasLayer

@export var fadeOutAnimName: String = "fade_out"
@export var fadeInAnimName: String = "fade_in"

@export var defaultFadeDuration: float = 0.4

@onready var animationPlayer: AnimationPlayer = $Control/AnimationPlayer

signal fade_started(anim_name: String)
signal fade_finished(anim_name: String)

func _ready() -> void:
	# Check for AnimationPlayer node and warn if missing
	if not animationPlayer:
		push_warning("AnimationPlayer node not found. SceneTransition fades will fallback to simple timers.")

func fadeOut() -> bool:
	# Perform fade out animation or fallback timer, skip if player dead
	if _isPlayerDead():
		print("[SceneTransition] Player is dead, skipping fadeOut")
		return true

	if get_tree().current_scene:
		get_tree().current_scene.visible = false

	if animationPlayer and animationPlayer.has_animation(fadeOutAnimName):
		emit_signal("fade_started", fadeOutAnimName)
		animationPlayer.play(fadeOutAnimName)
		await animationPlayer.animation_finished
		emit_signal("fade_finished", fadeOutAnimName)
		return true
	else:
		emit_signal("fade_started", "timer_fade_out")
		await get_tree().create_timer(defaultFadeDuration).timeout
		emit_signal("fade_finished", "timer_fade_out")
		return true

func fadeIn() -> bool:
	# Perform fade in animation or fallback timer, skip if player dead
	if _isPlayerDead():
		print("[SceneTransition] Player is dead, skipping fadeIn")
		return true

	if animationPlayer and animationPlayer.has_animation(fadeInAnimName):
		emit_signal("fade_started", fadeInAnimName)
		animationPlayer.play(fadeInAnimName)
		await animationPlayer.animation_finished
		emit_signal("fade_finished", fadeInAnimName)
		return true
	else:
		emit_signal("fade_started", "timer_fade_in")
		await get_tree().create_timer(defaultFadeDuration).timeout
		emit_signal("fade_finished", "timer_fade_in")
		return true

func _isPlayerDead() -> bool:
	# Check if player exists and is in Death state
	var player = PlayerManager.get_player()
	if player == null:
		return false
	var fsm = player.fsm
	if fsm == null:
		return false
	var currentState = fsm.currentState
	if currentState == null:
		return false
	return currentState.get_class() == "Death"
