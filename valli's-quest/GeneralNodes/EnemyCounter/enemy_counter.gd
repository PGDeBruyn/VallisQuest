class_name EnemyCounter
extends Node2D

signal enemiesDefeated

var trackedEnemies: Array = []

func _ready() -> void:
	_updateEnemyTracking()
	child_exiting_tree.connect(_onChildExiting)

func _updateEnemyTracking() -> void:
	trackedEnemies.clear()
	for child in get_children():
		if child is Enemy:
			trackedEnemies.append(child)

func _onChildExiting(child: Node) -> void:
	if child in trackedEnemies:
		trackedEnemies.erase(child)
		_checkEnemiesDefeated()

func _checkEnemiesDefeated() -> void:
	if trackedEnemies.is_empty():
		emit_signal("enemiesDefeated")

func getEnemyCount() -> int:
	return trackedEnemies.size()
