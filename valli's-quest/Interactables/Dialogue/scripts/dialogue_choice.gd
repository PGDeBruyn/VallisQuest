@tool
@icon("res://GUI/dialogue_system/icons/question_bubble.svg")
class_name DialogueChoice
extends DialogueItem

signal branchSelected(branch: DialogueBranch)

var _branches: Array[DialogueBranch] = []
var _initialized := false

func _ready() -> void:
	# Initialize branches unless in editor preview mode
	if Engine.is_editor_hint():
		return
	_initChoice()

func _initChoice() -> void:
	# Initialize branch cache once
	if _initialized:
		return
	_refreshBranches()
	_initialized = true

func get_branches() -> Array[DialogueBranch]:
	# Return cached branches, initializing if needed
	_initChoice()
	return _branches


func chooseBranch(branch: DialogueBranch) -> void:
	# Emit signals for branch selection
	branch.selected.emit()
	branchSelected.emit(branch)

func _refreshBranches() -> void:
	# Cache all child DialogueBranch nodes
	var result: Array[DialogueBranch] = []
	for child in get_children():
		if child is DialogueBranch:
			result.append(child)
	_branches = result

func _get_configuration_warnings() -> PackedStringArray:
	# Provide editor warnings for invalid setup
	if Engine.is_editor_hint():
		_refreshBranches()

	if _branches.size() < 2:
		return ["DialogueChoice should contain at least 2 DialogueBranch children."]
	return []

func _notification(what: int) -> void:
	# Refresh branches when child order changes in editor
	if what == NOTIFICATION_CHILD_ORDER_CHANGED and Engine.is_editor_hint():
		_refreshBranches()
