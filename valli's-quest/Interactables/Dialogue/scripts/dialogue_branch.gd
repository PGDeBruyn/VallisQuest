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
	# Initialize children loading unless in editor preview mode
	if Engine.is_editor_hint():
		return
	_loadChildrenIfNeeded()

func getItems() -> Array[DialogueItem]:
	# Return cached child DialogueItems, loading if needed
	_loadChildrenIfNeeded()
	return _cachedItems

func _loadChildrenIfNeeded() -> void:
	# Load child DialogueItems once and cache them
	if _initialized:
		return
	_refreshItems()
	_initialized = true

func _refreshItems() -> void:
	# Gather all child DialogueItems into the cache
	var items: Array[DialogueItem] = []
	for c in get_children():
		if c is DialogueItem:
			items.append(c)
	_cachedItems = items
