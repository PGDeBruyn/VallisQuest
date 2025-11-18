class_name EnemyStateIdle
extends EnemyState

var wanderState: EnemyState
@export var nextState: EnemyState

@export var animationName: String = "idle"

func _ready() -> void:
	wanderState = get_parent().get_node("Wander")  # adjust path as needed

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy._updateAnimation(animationName)

func exit() -> void:
	pass

func process(_delta: float) -> EnemyState:
	if should_start_wandering():
		return wanderState

	enemy.velocity = Vector2.ZERO
	return null

func physics(_delta: float) -> EnemyState:
	return null

func handleInput(_event: InputEvent) -> EnemyState:
	return null

func should_start_wandering() -> bool:
	return randi() % 100 < 1
