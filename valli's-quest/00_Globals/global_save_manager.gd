extends Node
class_name GlobalSaveManager

@export var saveFileName: String = "save.sav"
const SAVE_PATH := "user://"

signal game_loaded
signal game_saved

var current_save: Dictionary = {
	"scene_path": "",
	"player": {
		"hp": 1,
		"max_hp": 1,
		"posX": 0.0,
		"posY": 0.0
	},
	"items": [],
	"persistence": [],
	"quests": []
}

func save_game() -> void:
	_update_player_data()
	_update_scene_path()
	_update_item_data()

	if current_save["scene_path"] == "" or current_save["scene_path"] == null:
		push_error("Cannot save game: scene path is empty!")
		return
	
	var file_path = SAVE_PATH + saveFileName
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: %s" % file_path)
		return
	
	var save_json = JSON.stringify(current_save)
	file.store_line(save_json)
	file.close()
	emit_signal("game_saved")

func load_game() -> void:
	var file_path = SAVE_PATH + saveFileName
	if not FileAccess.file_exists(file_path):
		push_warning("Save file does not exist: %s" % file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading: %s" % file_path)
		return
	
	var json_text = file.get_line()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("Failed to parse save JSON: %s" % json.get_error_message())
		return
	
	var save_dict: Dictionary = json.get_data()
	
	# Defensive copy with fallback to default if keys missing
	current_save = save_dict if save_dict is Dictionary else current_save
	
	if current_save.get("scene_path", "") == "":
		push_error("No valid scene path saved!")
		return
	
	LevelManager.loadNewLevel(
		current_save.get("scene_path", ""),
		"",
		Vector2.ZERO
	)
	await LevelManager.level_load_initiated
	
	PlayerManager.set_player_position(Vector2(
		current_save["player"].get("posX", 0),
		current_save["player"].get("posY", 0)
	))
	PlayerManager.set_health(
		current_save["player"].get("hp", 1),
		current_save["player"].get("max_hp", 1)
	)
	PlayerManager.INVENTORY_DATA.parseSaveData(current_save.get("items", []))
	
	await LevelManager.level_load_completed
	emit_signal("game_loaded")

func addPersistentValue(value: String) -> void:
	if not checkPersistentValue(value):
		current_save["persistence"].append(value)

func checkPersistentValue(value: String) -> bool:
	return current_save.get("persistence", []).has(value)

# --- Private helper methods ---

func _update_player_data() -> void:
	var p = PlayerManager.player
	if p:
		current_save["player"]["hp"] = p.health
		current_save["player"]["max_hp"] = p.maxHealth
		current_save["player"]["posX"] = p.global_position.x
		current_save["player"]["posY"] = p.global_position.y

func _update_scene_path() -> void:
	current_save["scene_path"] = LevelManager.currentScenePath

func _update_item_data() -> void:
	current_save["items"] = PlayerManager.INVENTORY_DATA.getSaveData()
