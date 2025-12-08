extends Node

signal currency_changed(new_amount: int)
signal player_spawned(player: Player)
signal player_died()
signal interactPressed

const PLAYER_SCENE = preload("uid://dosoxf3yfv1xw")
const INVENTORY_DATA: InventoryData = preload("res://GUI/PauseMenu/Inventory/player_inventory.tres")

var player: Player = null
var _is_spawning: bool = false

var _gemAmount: int = 0

# Sets the player's gem amount and emits the currency change signal
func setGemAmount(value: int) -> void:
	if _gemAmount == value:
		return
	_gemAmount = value
	emit_signal("currency_changed", _gemAmount)

# Returns the current gem amount
func getGemAmount() -> int:
	return _gemAmount

# Adds the given number of gems to the total
func addGems(amount: int) -> void:
	setGemAmount(_gemAmount + amount)

# Attempts to spend gems and returns whether it succeeded
func spendGems(amount: int) -> bool:
	if _gemAmount >= amount:
		setGemAmount(_gemAmount - amount)
		return true
	return false

# Returns the player, spawning one if necessary
func get_player() -> Player:
	if player == null and not _is_spawning:
		_spawn_player()
	return player

# Spawns the player instance and emits the spawn signal
func _spawn_player() -> void:
	_is_spawning = true
	player = PLAYER_SCENE.instantiate() as Player
	add_child(player)
	if player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))
	if player.has_signal("revived"):
		player.connect("revived", Callable(self, "_on_player_revived"))
	emit_signal("player_spawned", player)
	_is_spawning = false

# Removes the player and emits the death signal
func remove_player() -> void:
	if player:
		player.queue_free()
		player = null
		emit_signal("player_died")

# Sets the player's position if they exist
func set_player_position(position: Vector2) -> void:
	if get_player():
		player.global_position = position

# Reparents the player to a new parent node
func set_parent(new_parent: Node) -> void:
	if get_player():
		var current_parent = player.get_parent()
		if current_parent:
			current_parent.remove_child(player)
		new_parent.add_child(player)

# Removes the player from its current parent
func unparent_player() -> void:
	if get_player():
		var current_parent = player.get_parent()
		if current_parent:
			current_parent.remove_child(player)

# Plays a sound effect on the player
func play_audio(audio: AudioStream) -> void:
	if get_player() and player.sfx:
		player.sfx.stream = audio
		player.sfx.play()

# Sets the player’s current and max health
func set_health(health_val: int, max_health_val: int) -> void:
	if get_player():
		if "setHealth" in player:
			player.setHealth(health_val, max_health_val)
		else:
			player._updateHealth(health_val)
			player.maxHealth = max_health_val

# Returns a dictionary containing player health info
func get_health() -> Dictionary:
	if get_player():
		return {
			"health": player.health,
			"maxHealth": player.maxHealth
		}
	return {}

# Returns the player's inventory data
func get_inventory() -> InventoryData:
	return INVENTORY_DATA

# Reparents the player to a new node (duplicate method)
func reparentPlayer(new_parent: Node) -> void:
	if get_player():
		var current_parent = player.get_parent()
		if current_parent:
			current_parent.remove_child(player)
		new_parent.add_child(player)

# Emits the player_died signal when the player dies
func _on_player_died() -> void:
	emit_signal("player_died")

# Handles player revival events
func _on_player_revived() -> void:
	pass
