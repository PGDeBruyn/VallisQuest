class_name EnemyStateIdle
extends EnemyState

var wanderState: EnemyState
@export var nextState: EnemyState

@export var animationName: String = "idle"

# Initializes references when the node is ready.
func _ready() -> void:
	wanderState = get_parent().get_node("Wander")

# Sets idle animation and ensures the enemy does not move.
func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy._updateAnimation(animationName)

# Called when leaving the idle state.
func exit() -> void:
	pass

# Handles idle behavior and decides whether to switch to wander.
func process(_delta: float) -> EnemyState:
	if should_start_wandering():
		return wanderState

	enemy.velocity = Vector2.ZERO
	return null

# Placeholder for physics-related logic during idle.
func physics(_delta: float) -> EnemyState:
	return null

# Processes input if needed while in idle.
func handleInput(_event: InputEvent) -> EnemyState:
	return null

# Determines whether the enemy should randomly start wandering.
func should_start_wandering() -> bool:
	return randi() % 100 < 1
