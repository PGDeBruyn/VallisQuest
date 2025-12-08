class_name PlayerStateMachine
extends Node

# List of all State nodes this machine manages
var states: Array[State] = []

# References to track previous and current active states
var previousState: State = null
var currentState: State = null

func _ready() -> void:
	# Disable processing by default until initialized
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	# Called every frame; delegate logic update to current state
	if currentState:
		var nextState = currentState.process(delta)
		_changeState(nextState)  # Attempt transition if a new state is returned

func _physics_process(delta: float) -> void:
	# Called every physics frame; delegate physics update to current state
	if currentState:
		var nextState = currentState.physics(delta)
		_changeState(nextState)  # Attempt transition if a new state is returned

func _unhandled_input(event: InputEvent) -> void:
	# Pass input events to current state for handling
	if currentState:
		var nextState = currentState.handleInput(event)
		_changeState(nextState)  # Attempt transition if a new state is returned

# Called externally by Player to initialize this state machine with player reference
func initialize(playerRef: Player) -> void:
	states.clear()
	# Collect all child nodes that are of type State
	for child in get_children():
		if child is State:
			states.append(child)

	if states.is_empty():
		return

	# Initialize each state with references to player and this state machine
	for state in states:
		# Support both old (initState) and new (init) initialization method signatures
		if state.has_method("initState"):
			state.initState(playerRef, self)
		elif state.has_method("init"):
			state.init()

	# Start with the first state (usually Idle or default)
	_changeState(states[0])

	# Enable processing now that states are initialized
	process_mode = Node.PROCESS_MODE_INHERIT

# Public method to request a state change
func changeState(newState: State) -> void:
	_changeState(newState)

# Core internal logic to handle state transitions
func _changeState(newState: State) -> void:
	# Ignore if no new state or same as current
	if newState == null or newState == currentState:
		return

	# Prevent leaving stun state early unless transitioning to Death
	if currentState is StateStun:
		var stun = currentState as StateStun
		if stun.stunTimer < stun.stunDuration:
			# Allow only if going to death state
			if not (newState is StateDeath):
				return

	# Exit current state cleanly
	if currentState:
		currentState.exit()

	previousState = currentState
	currentState = newState
	# Enter new state
	currentState.enter()

# Helper method to find a state by class name first, then by node name
func findStateByClassOrName(className: String, nodeName: String) -> State:
	# Search states by class name first
	for s in states:
		if s.get_class() == className:
			return s
	# If not found, search by node name
	for s in states:
		if s.name == nodeName:
			return s
	return null  # Not found
