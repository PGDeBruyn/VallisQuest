class_name EnemyState
extends Node

var enemy: Enemy
var stateMachine: EnemyStateMachine

# Initializes the state with references to the enemy and state machine
func init(_enemy: Enemy, _stateMachine: EnemyStateMachine) -> void:
	enemy = _enemy
	stateMachine = _stateMachine

# Returns whether this state counts as a critical state
func is_in_critical_state() -> bool:
	return false

# Handles state processing logic each frame
func process(_delta: float) -> EnemyState:
	return null

# Handles physics-related state logic
func physics(_delta: float) -> EnemyState:
	return null

# Called when the state becomes active
func enter() -> void:
	pass

# Called when the state stops being active
func exit() -> void:
	pass
