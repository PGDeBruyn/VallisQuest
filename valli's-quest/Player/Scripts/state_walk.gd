class_name StateWalk extends State

@export var moveSpeed: float = 100.0

var idleState: State
var attackState: State

func _ready() -> void:
	idleState = get_parent().get_node("Idle")
	attackState = get_parent().get_node("Attack")

func enter() -> void:
	player.playStateAnim("walk")

func exit() -> void:
	pass

func process(_delta: float) -> State:
	if player.velocity == Vector2.ZERO:
		return idleState

	player.velocity = player.velocity.normalized() * moveSpeed

	
	return null

func physics(_delta: float) -> State:
	return null

func handleInput(event: InputEvent) -> State:
	if event.is_action_pressed("attack"):
		return attackState
	if event.is_action_pressed("interact"):
		PlayerManager.interactPressed.emit()
	return null
