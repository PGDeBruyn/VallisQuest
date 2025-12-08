class_name State
extends Node

# References to the player and the state machine.
# These are instance variables set during initialization.
var player: Player
var stateMachine: PlayerStateMachine

func _ready() -> void:
	# Called when the node is added to the scene.
	# Default does nothing, override in subclasses if needed.
	pass

func initState(playerRef: Player, stateMachineRef: PlayerStateMachine) -> void:
	# Initialize references to player and state machine.
	player = playerRef
	stateMachine = stateMachineRef

func enter() -> void:
	# Called when the state becomes active.
	# Override in subclasses to set up state-specific behavior.
	pass

func exit() -> void:
	# Called when the state is being exited.
	# Override in subclasses to clean up or reset things.
	pass

func process(_delta: float) -> State:
	# Called every frame (non-physics).
	# Override to define per-frame logic.
	# Return a new State to transition, or null to remain.
	return null

func physics(_delta: float) -> State:
	# Called every physics frame.
	# Override to define physics-related logic.
	# Return a new State to transition, or null to remain.
	return null

func handleInput(_event: InputEvent) -> State:
	# Called when an input event is received.
	# Override to handle player input.
	# Return a new State to transition, or null to remain.
	return null
