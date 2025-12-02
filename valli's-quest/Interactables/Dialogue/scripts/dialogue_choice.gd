@tool
@icon("res://GUI/dialogue_system/icons/question_bubble.svg")
class_name DialogueChoice
extends DialogueItem

signal branchSelected(branch: DialogueBranch)

var _branches: Array[DialogueBranch] = []
var _initialized := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_initChoice()


## ------------------------------------------------------------------
## INITIALIZATION
## ------------------------------------------------------------------

func _initChoice() -> void:
	if _initialized:
		return
	_refreshBranches()
	_initialized = true


## ------------------------------------------------------------------
## PUBLIC ACCESS
## ------------------------------------------------------------------

func get_branches() -> Array[DialogueBranch]:
	_initChoice()
	return _branches


# NEW — required for branch selection events
func chooseBranch(branch: DialogueBranch) -> void:
	branch.selected.emit()
	branchSelected.emit(branch)


## ------------------------------------------------------------------
## BRANCH CACHE
## ------------------------------------------------------------------

func _refreshBranches() -> void:
	var result: Array[DialogueBranch] = []
	for child in get_children():
		if child is DialogueBranch:
			result.append(child)
	_branches = result


## ------------------------------------------------------------------
## EDITOR FEEDBACK
## ------------------------------------------------------------------

func _get_configuration_warnings() -> PackedStringArray:
	if Engine.is_editor_hint():
		_refreshBranches()

	if _branches.size() < 2:
		return ["DialogueChoice should contain at least 2 DialogueBranch children."]
	return []

func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED and Engine.is_editor_hint():
		_refreshBranches()
