@tool
@icon("res://GUI/dialogue_system/icons/question_bubble.svg")
class_name DialogueBranch
extends DialogueItem

signal selected

@export var text: String = "ok..."
@export var opensShop: bool = false

var _cachedItems: Array[DialogueItem] = []
var _initialized := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_loadChildrenIfNeeded()

func getItems() -> Array[DialogueItem]:
	_loadChildrenIfNeeded()
	return _cachedItems

func _loadChildrenIfNeeded() -> void:
	if _initialized:
		return
	_refreshItems()
	_initialized = true

func _refreshItems() -> void:
	var items: Array[DialogueItem] = []
	for c in get_children():
		if c is DialogueItem:
			items.append(c)
	_cachedItems = items
