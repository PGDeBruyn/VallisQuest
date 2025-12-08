class_name StateIdle
extends State

var walkState: State
var attackState: State

func _ready() -> void:
	# Cache references to sibling states for transitions
	walkState = get_parent().get_node("Walk")
	attackState = get_parent().get_node("Attack")

func enter() -> void:
	# Play idle animation when entering idle state
	player.playStateAnim("idle")

func exit() -> void:
	# No special cleanup needed on exit
	pass

func process(_delta: float) -> State:
	# Transition to Walk state if player is moving
	if player.velocity != Vector2.ZERO:
		return walkState

	# Ensure velocity is zero when idle
	player.velocity = Vector2.ZERO
	return null  # Stay in Idle state otherwise

func physics(_delta: float) -> State:
	# No physics logic needed in idle
	return null

func handleInput(event: InputEvent) -> State:
	# Attack input triggers transition to Attack state
	if event.is_action_pressed("attack"):
		return attackState

	# Interact input emits interaction signal (no state change)
	if event.is_action_pressed("interact"):
		PlayerManager.interactPressed.emit()

	return null  # No state change by default
