class_name EnemyStateMachine
extends Node

var states: Array[EnemyState] = []
var previousState: EnemyState = null
var currentState: EnemyState = null
var enemy: Enemy = null

# Disables processing until initialized.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

# Calls current state's process method and updates state if needed.
func _process(delta: float) -> void:
	if currentState:
		var next_state = currentState.process(delta)
		changeState(next_state)

# Calls current state's physics method and updates state if needed.
func _physics_process(delta: float) -> void:
	if currentState:
		var next_state = currentState.physics(delta)
		changeState(next_state)

# Initializes state machine with enemy and sets up states.
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

# Changes the current state, respecting critical states.
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
