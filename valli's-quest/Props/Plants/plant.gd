extends Node2D
class_name Plant

# Cache hitbox node for cleaner signal handling
var hitbox: Node = null

func _enter_tree() -> void:
	# Cache hitbox early in the node lifecycle
	hitbox = get_node("HitBox")
	# Connect signal with a lambda for inline brevity
	hitbox.damaged.connect(func(_damage):
		_destroy()
	)

func _destroy() -> void:
	# Could add drops here if I wanted
	queue_free()
