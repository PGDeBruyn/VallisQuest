extends Area2D

func _ready() -> void:
	var enteredCallable = Callable(self, "_handle_body_entered")
	var exitedCallable = Callable(self, "_handle_body_exited")

	if not is_connected("body_entered", enteredCallable):
		connect("body_entered", enteredCallable)
	if not is_connected("body_exited", exitedCallable):
		connect("body_exited", exitedCallable)

func _handle_body_entered(body: Node) -> void:
	if not _is_pushable_statue(body):
		return

	var player = PlayerManager.player
	if player == null:
		push_warning("Player reference not found!")
		return

	var direction = _get_player_movement_direction(player)
	body.pushDirection = direction
	print("PushArea: Body entered, setting pushDirection to ", direction)

func _handle_body_exited(body: Node) -> void:
	if not _is_pushable_statue(body):
		return

	body.pushDirection = Vector2.ZERO
	print("PushArea: Body exited, resetting pushDirection")

func _is_pushable_statue(obj: Object) -> bool:
	return obj is PushableStatue

func _get_player_movement_direction(player: Player) -> Vector2:
	var vel = player.velocity
	if vel.length_squared() > 0.001:
		return vel.normalized()
	return Vector2.ZERO
