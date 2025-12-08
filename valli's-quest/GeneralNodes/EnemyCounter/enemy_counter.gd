class_name EnemyCounter
extends Node2D

signal enemiesDefeated

var trackedEnemies: Array = []

# Initializes enemy tracking and connects to child exit signal.
func _ready() -> void:
	_updateEnemyTracking()
	child_exiting_tree.connect(_onChildExiting)

# Refreshes the list of currently tracked Enemy nodes.
func _updateEnemyTracking() -> void:
	trackedEnemies.clear()
	for child in get_children():
		if child is Enemy:
			trackedEnemies.append(child)

# Removes enemies from tracking when they exit the scene tree.
func _onChildExiting(child: Node) -> void:
	if child in trackedEnemies:
		trackedEnemies.erase(child)
		_checkEnemiesDefeated()

# Checks if all tracked enemies are defeated and emits signal if so.
func _checkEnemiesDefeated() -> void:
	if trackedEnemies.is_empty():
		emit_signal("enemiesDefeated")

# Returns the current count of tracked enemies.
func getEnemyCount() -> int:
	return trackedEnemies.size()
