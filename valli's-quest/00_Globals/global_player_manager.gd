extends Node

signal currency_changed(new_amount: int)
signal player_spawned(player: Player)
signal player_died()
signal interactPressed

const PLAYER_SCENE = preload("uid://dosoxf3yfv1xw")  # Your player scene path
const INVENTORY_DATA: InventoryData = preload("res://GUI/PauseMenu/Inventory/player_inventory.tres")

var player: Player = null
var _is_spawning: bool = false

var _gemAmount: int = 0

func setGemAmount(value: int) -> void:
	if _gemAmount == value:
		return
	_gemAmount = value
	emit_signal("currency_changed", _gemAmount)

func getGemAmount() -> int:
	return _gemAmount

func addGems(amount: int) -> void:
	setGemAmount(_gemAmount + amount)

func spendGems(amount: int) -> bool:
	if _gemAmount >= amount:
		setGemAmount(_gemAmount - amount)
		return true
	return false

func get_player() -> Player:
	if player == null and not _is_spawning:
		_spawn_player()
	return player

func _spawn_player() -> void:
	_is_spawning = true
	player = PLAYER_SCENE.instantiate() as Player
	add_child(player)
	
	# Connect player's died and revived signals properly with Callable
	if player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))
	if player.has_signal("revived"):
		player.connect("revived", Callable(self, "_on_player_revived"))
		
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

func set_health(health_val: int, max_health_val: int) -> void:
	if get_player():
		if "setHealth" in player:
			player.setHealth(health_val, max_health_val)
		else:
			player._updateHealth(health_val)  # fallback if no public method
			player.maxHealth = max_health_val

func get_health() -> Dictionary:
	if get_player():
		return {
			"health": player.health,
			"maxHealth": player.maxHealth
		}
	return {}

func get_inventory() -> InventoryData:
	return INVENTORY_DATA

func reparentPlayer(new_parent: Node) -> void:
	if get_player():
		var current_parent = player.get_parent()
		if current_parent:
			current_parent.remove_child(player)
		new_parent.add_child(player)

# Called when player dies
func _on_player_died() -> void:
	emit_signal("player_died")

# Called when player revives
func _on_player_revived() -> void:
	# You can handle any special logic here on revival if needed
	pass
