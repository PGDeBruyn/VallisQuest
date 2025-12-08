@icon("res://npc/icons/npc_behavior.svg")
class_name NPCBehavior
extends Node2D

var npc: NPC

func _ready() -> void:
	# Get reference to the parent NPC node
	npc = get_parent() as NPC
	# Connect to the NPC's behavior_toggled signal to respond to behavior state changes
	if npc:
		npc.connect("behavior_toggled", Callable(self, "_onBehaviorToggled"))


func _onBehaviorToggled(enabled: bool) -> void:
	# Called when the NPC behavior is toggled on or off
	# Start or stop this behavior accordingly
	if enabled:
		start()
	else:
		stop()

func start() -> void:
	# Placeholder function to start this behavior
	# Intended to be overridden in subclasses with specific behavior logic
	pass

func stop() -> void:
	# Placeholder function to stop this behavior
	# Intended to be overridden in subclasses with specific behavior logic
	pass
