# EnemyState.gd
class_name EnemyState
extends Node

var enemy: Enemy
var stateMachine: EnemyStateMachine

func init(_enemy: Enemy, _stateMachine: EnemyStateMachine) -> void:
	enemy = _enemy
	stateMachine = _stateMachine

func is_in_critical_state() -> bool:
	return false  # override in stun or similar states

func process(_delta: float) -> EnemyState:
	# Your state logic here
	return null

func physics(_delta: float) -> EnemyState:
	# Physics logic here
	return null

func enter() -> void:
	pass

func exit() -> void:
	pass
