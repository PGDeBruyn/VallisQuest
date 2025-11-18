class_name PlayerStateMachine
extends Node

var states: Array[State] = []
var previousState: State = null
var currentState: State = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if currentState:
		var nextState = currentState.process(delta)
		_changeState(nextState)

func _physics_process(delta: float) -> void:
	if currentState:
		var nextState = currentState.physics(delta)
		_changeState(nextState)

func _unhandled_input(event: InputEvent) -> void:
	if currentState:
		var nextState = currentState.handleInput(event)
		_changeState(nextState)

func initialize(playerRef: Player) -> void:
	states.clear()
	for child in get_children():
		if child is State:
			states.append(child)

	if states.is_empty():
		return

	# Initialize all states with player and state machine references
	for state in states:
		state.initState(playerRef, self)

	_changeState(states[0])
	process_mode = Node.PROCESS_MODE_INHERIT

func _changeState(newState: State) -> void:
	if newState == null or newState == currentState:
		return

	# Prevent leaving stun early
	if currentState is StateStun and currentState.stunTimer < currentState.stunDuration:
		# Don't switch states until stun finished
		return

	if currentState:
		currentState.exit()

	previousState = currentState
	currentState = newState
	currentState.enter()
