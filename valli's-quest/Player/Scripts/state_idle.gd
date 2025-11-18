class_name StateIdle extends State

var walkState: State
var attackState: State

func _ready() -> void:
	walkState = get_parent().get_node("Walk")
	attackState = get_parent().get_node("Attack")

func enter() -> void:
	player.playStateAnim("idle")

func exit() -> void:
	pass

func process(_delta: float) -> State:
	if player.velocity != Vector2.ZERO:
		return walkState
	player.velocity = Vector2.ZERO
	return null

func physics(_delta: float) -> State:
	return null

func handleInput(event: InputEvent) -> State:
	if event.is_action_pressed("attack"):
		return attackState
	if event.is_action_pressed("interact"):
		PlayerManager.interactPressed.emit()
	return null
