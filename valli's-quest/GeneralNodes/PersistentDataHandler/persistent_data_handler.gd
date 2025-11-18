class_name PersistentDataHandler
extends Node

signal dataLoaded

var value: bool = false

func _ready() -> void:
	_refresh_local_state()

func setValue() -> void:
	var key = _compose_key()
	SaveManager.addPersistentValue(key)
	value = true

func getValue() -> void:
	_refresh_local_state()

func getName() -> String:
	return _compose_key()

func _refresh_local_state() -> void:
	var key = _compose_key()
	value = SaveManager.checkPersistentValue(key)
	dataLoaded.emit()

func _compose_key() -> String:
	var scene_path := ""
	var current_scene := get_tree().current_scene
	if current_scene:
		scene_path = current_scene.scene_file_path

	var parent_name := ""
	if get_parent():
		parent_name = get_parent().name

	return "%s::%s::%s" % [scene_path, parent_name, name]
