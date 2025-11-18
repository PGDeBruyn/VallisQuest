class_name State
extends Node

# Reference to the player and state machine — instance variables, not static
var player: Player
var stateMachine: PlayerStateMachine

func _ready() -> void:
	pass

func initState(playerRef: Player, stateMachineRef: PlayerStateMachine) -> void:
	player = playerRef
	stateMachine = stateMachineRef

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> State:
	return null

func physics(_delta: float) -> State:
	return null

func handleInput(_event: InputEvent) -> State:
	return null
