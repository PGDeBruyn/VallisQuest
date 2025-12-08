class_name StateWalk
extends State

@export var moveSpeed: float = 100.0  # Movement speed while walking

var idleState: State
var attackState: State

func _ready() -> void:
	# Cache references to Idle and Attack states for transitions
	idleState = get_parent().get_node("Idle")
	attackState = get_parent().get_node("Attack")

func enter() -> void:
	# Play walking animation when entering walk state
	player.playStateAnim("walk")

func exit() -> void:
	# No special cleanup needed on exit
	pass

func process(_delta: float) -> State:
	# If player stops moving, switch to Idle state
	if player.velocity == Vector2.ZERO:
		return idleState

	# Normalize velocity vector and scale by moveSpeed to maintain consistent speed
	player.velocity = player.velocity.normalized() * moveSpeed

	# Stay in Walk state otherwise
	return null

func physics(_delta: float) -> State:
	# No physics-specific logic needed here
	return null

func handleInput(event: InputEvent) -> State:
	# If attack button pressed, transition to Attack state
	if event.is_action_pressed("attack"):
		return attackState
	# If interact button pressed, emit interaction signal
	if event.is_action_pressed("interact"):
		PlayerManager.interactPressed.emit()
	return null
