@tool
@icon("res://GUI/dialogue_system/icons/chat_bubble.svg")
class_name DialogueItem
extends Node

@export var npcInfo: NPCResource

func _ready() -> void:
	# Assign NPC info from parent NPC if not set, unless in editor
	if Engine.is_editor_hint():
		return
	_assignNpcInfoIfMissing()

func _assignNpcInfoIfMissing() -> void:
	# Traverse parents to find NPC node and assign its npcResource if npcInfo is null
	if npcInfo == null:
		var p = self.get_parent()
		while p != null:
			if p is NPC and p.npcResource:
				npcInfo = p.npcResource
				break
			p = p.get_parent()
