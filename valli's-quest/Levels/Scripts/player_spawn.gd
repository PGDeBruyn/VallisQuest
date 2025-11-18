extends Node2D

func _ready() -> void:
	visible = false

	var player = PlayerManager.get_player()

	if player:
		player.global_position = global_position
