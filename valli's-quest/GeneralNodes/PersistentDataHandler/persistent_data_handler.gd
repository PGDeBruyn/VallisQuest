class_name PersistentDataHandler
extends Node

signal dataLoaded

var value: bool = false

# Initializes the local state on ready.
func _ready() -> void:
	_refresh_local_state()

# Sets the persistent value in the save manager.
func setValue() -> void:
	var key = _compose_key()
	SaveManager.addPersistentValue(key)
	value = true

# Refreshes the local value from the save manager.
func getValue() -> void:
	_refresh_local_state()

# Returns the composed unique key for this data handler.
func getName() -> String:
	return _compose_key()

# Updates the local state by checking the save manager.
func _refresh_local_state() -> void:
	var key = _compose_key()
	value = SaveManager.checkPersistentValue(key)
	dataLoaded.emit()

# Composes a unique key based on scene, parent, and node name.
func _compose_key() -> String:
	var scene_path := ""
	var current_scene := get_tree().current_scene
	if current_scene:
		scene_path = current_scene.scene_file_path

	var parent_name := ""
	if get_parent():
		parent_name = get_parent().name

	return "%s::%s::%s" % [scene_path, parent_name, name]
