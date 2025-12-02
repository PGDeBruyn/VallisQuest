# PlayerStateMachine.gd
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

# External initializer called by Player
func initialize(playerRef: Player) -> void:
	states.clear()
	for child in get_children():
		if child is State:
			states.append(child)

	if states.is_empty():
		return

	# Initialize all states with player and state machine references
	for state in states:
		# Support old/new state init signatures by calling initState if present
		if state.has_method("initState"):
			state.initState(playerRef, self)
		elif state.has_method("init"):
			state.init()

	# Start with the first state found (usually Idle)
	_changeState(states[0])
	process_mode = Node.PROCESS_MODE_INHERIT

# Public alias used by tutorial code and other states
func changeState(newState: State) -> void:
	_changeState(newState)

# Core transition logic
func _changeState(newState: State) -> void:
	if newState == null or newState == currentState:
		return

	# Prevent leaving stun early *except* to go to Death
	if currentState is StateStun:
		# Access stun timer/duration to determine if stun still active
		var stun = currentState as StateStun
		if stun.stunTimer < stun.stunDuration:
			# allow early transition *only* if newState is a Death-like state
			if not (newState is StateDeath):
				return

	if currentState:
		currentState.exit()

	previousState = currentState
	currentState = newState
	currentState.enter()

# helper: find state by class name first, then by node name
func findStateByClassOrName(className: String, nodeName: String) -> State:
	for s in states:
		if s.get_class() == className:
			return s
	for s in states:
		if s.name == nodeName:
			return s
	return null
