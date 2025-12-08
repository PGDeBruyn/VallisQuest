extends Area2D

func _ready() -> void:
	# Create callable references for signal handlers
	var enteredCallable = Callable(self, "_handle_body_entered")
	var exitedCallable = Callable(self, "_handle_body_exited")

	# Connect signals if not already connected
	if not is_connected("body_entered", enteredCallable):
		connect("body_entered", enteredCallable)
	if not is_connected("body_exited", exitedCallable):
		connect("body_exited", exitedCallable)

func _handle_body_entered(body: Node) -> void:
	# Only process bodies that are PushableStatue
	if not _is_pushable_statue(body):
		return

	# Get the player reference to determine push direction
	var player = PlayerManager.player
	if player == null:
		push_warning("Player reference not found!")
		return

	# Get the player's current movement direction and assign it to the statue's pushDirection
	var direction = _get_player_movement_direction(player)
	body.pushDirection = direction
	print("PushArea: Body entered, setting pushDirection to ", direction)

func _handle_body_exited(body: Node) -> void:
	# Only process bodies that are PushableStatue
	if not _is_pushable_statue(body):
		return

	# Reset the pushDirection when the body exits the area
	body.pushDirection = Vector2.ZERO
	print("PushArea: Body exited, resetting pushDirection")

func _is_pushable_statue(obj: Object) -> bool:
	# Helper to check if the object is a PushableStatue
	return obj is PushableStatue

func _get_player_movement_direction(player: Player) -> Vector2:
	# Return the player's normalized velocity if moving; else zero vector
	var vel = player.velocity
	if vel.length_squared() > 0.001:
		return vel.normalized()
	return Vector2.ZERO
