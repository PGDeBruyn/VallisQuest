extends Node

signal player_spawned(player: Player)
signal player_died()
signal interactPressed

const PLAYER_SCENE = preload("uid://dosoxf3yfv1xw")  # Replace with your actual path
const INVENTORY_DATA: InventoryData = preload("res://GUI/PauseMenu/Inventory/player_inventory.tres")

var player: Player = null
var _is_spawning: bool = false

func get_player() -> Player:
	# Lazy creation of the player instance
	if player == null and not _is_spawning:
		_spawn_player()
	return player

func _spawn_player() -> void:
	_is_spawning = true
	player = PLAYER_SCENE.instantiate() as Player
	add_child(player)
	emit_signal("player_spawned", player)
	_is_spawning = false

func remove_player() -> void:
	if player:
		player.queue_free()
		player = null
		emit_signal("player_died")

func set_player_position(position: Vector2) -> void:
	if get_player():
		player.global_position = position

func set_parent(new_parent: Node) -> void:
	if get_player():
		var current_parent = player.get_parent()
		if current_parent:
			current_parent.remove_child(player)
		new_parent.add_child(player)

func unparent_player() -> void:
	if get_player():
		var current_parent = player.get_parent()
		if current_parent:
			current_parent.remove_child(player)

func play_audio(audio: AudioStream) -> void:
	if get_player() and player.sfx:
		player.sfx.stream = audio
		player.sfx.play()

# UPDATED methods to work with Player's health naming
func set_health(health_val: int, max_health_val: int) -> void:
	if get_player():
		# Use a public method in Player if you have one (recommended)
		if "setHealth" in player:
			player.setHealth(health_val, max_health_val)
		else:
			# Directly set properties if no public method exists (less safe)
			player._updateHealth(health_val)  # Note: underscore means private, so this is a hack
			player.maxHealth = max_health_val

func get_health() -> Dictionary:
	if get_player():
		return {
			"health": player.health,
			"maxHealth": player.maxHealth
		}
	return {}

func get_inventory():
	return INVENTORY_DATA  # or wherever your inventory instance is

# NEW method added to fix your error (reparent player safely)
func reparentPlayer(new_parent: Node) -> void:
	if get_player():
		var current_parent = player.get_parent()
		if current_parent:
			current_parent.remove_child(player)
		new_parent.add_child(player)
