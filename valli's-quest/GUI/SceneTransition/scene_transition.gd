extends CanvasLayer

@export var fadeOutAnimName: String = "fade_out"
@export var fadeInAnimName: String = "fade_in"

@export var defaultFadeDuration: float = 0.4

@onready var animationPlayer: AnimationPlayer = $Control/AnimationPlayer

signal fade_started(anim_name: String)
signal fade_finished(anim_name: String)

func _ready() -> void:
	if not animationPlayer:
		push_warning("AnimationPlayer node not found. SceneTransition fades will fallback to simple timers.")

# Plays fade_out animation and waits until finished
func fadeOut() -> bool:
	if animationPlayer and animationPlayer.has_animation(fadeOutAnimName):
		emit_signal("fade_started", fadeOutAnimName)
		animationPlayer.play(fadeOutAnimName)
		await animationPlayer.animation_finished
		emit_signal("fade_finished", fadeOutAnimName)
		return true
	else:
		# Fallback: no animation, just wait timer
		emit_signal("fade_started", "timer_fade_out")
		await get_tree().create_timer(defaultFadeDuration).timeout
		emit_signal("fade_finished", "timer_fade_out")
		return true

# Plays fade_in animation and waits until finished
func fadeIn() -> bool:
	if animationPlayer and animationPlayer.has_animation(fadeInAnimName):
		emit_signal("fade_started", fadeInAnimName)
		animationPlayer.play(fadeInAnimName)
		await animationPlayer.animation_finished
		emit_signal("fade_finished", fadeInAnimName)
		return true
	else:
		# Fallback: no animation, just wait timer
		emit_signal("fade_started", "timer_fade_in")
		await get_tree().create_timer(defaultFadeDuration).timeout
		emit_signal("fade_finished", "timer_fade_in")
		return true
