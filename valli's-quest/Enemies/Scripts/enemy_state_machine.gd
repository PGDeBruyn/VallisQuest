# EnemyStateMachine.gd
class_name EnemyStateMachine
extends Node

var states: Array[EnemyState] = []
var previousState: EnemyState = null
var currentState: EnemyState = null
var enemy: Enemy = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if currentState:
		var next_state = currentState.process(delta)
		changeState(next_state)

func _physics_process(delta: float) -> void:
	if currentState:
		var next_state = currentState.physics(delta)
		changeState(next_state)

func initialize(enemy_ref: Enemy) -> void:
	enemy = enemy_ref
	states.clear()

	for child in get_children():
		if child is EnemyState:
			states.append(child)

	if states.is_empty():
		return

	for state in states:
		state.init(enemy, self)

	changeState(states[0])
	process_mode = Node.PROCESS_MODE_INHERIT

func changeState(new_state: EnemyState) -> void:
	if new_state == null or new_state == currentState:
		return

	if currentState and currentState.is_in_critical_state():
		return

	if currentState:
		currentState.exit()

	previousState = currentState
	currentState = new_state
	currentState.enter()
