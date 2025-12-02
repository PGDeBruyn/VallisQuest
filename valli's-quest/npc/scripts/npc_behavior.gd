@icon("res://npc/icons/npc_behavior.svg")
class_name NPCBehavior
extends Node2D

var npc: NPC

func _ready() -> void:
	npc = get_parent() as NPC
	if npc:
		npc.connect("behavior_toggled", Callable(self, "_onBehaviorToggled"))


func _onBehaviorToggled(enabled: bool) -> void:
	if enabled:
		start()
	else:
		stop()

func start() -> void:
	# Override in subclasses
	pass

func stop() -> void:
	# Override in subclasses
	pass
