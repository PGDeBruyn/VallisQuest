extends Node2D

func _ready() -> void:
	# Initially hide this node
	visible = false

	# Attempt to get the player node
	var player = PlayerManager.get_player()

	# If the player exists, set their global position to this node's position
	if player:
		player.global_position = global_position
