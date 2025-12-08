extends Node
class_name GlobalSaveManager

const SAVE_PATH: String = "user://"

@export var saveFileName: String = "save.sav"

signal gameLoaded
signal gameSaved

var currentSave: Dictionary = {
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

# Saves all game data to a JSON file
func save_game() -> void:
	_updatePlayerData()
	_updateScenePath()
	_updateItemData()

	if currentSave["scene_path"] == "" or currentSave["scene_path"] == null:
		push_error("Cannot save game: scene path is empty!")
		return

	var filePath: String = SAVE_PATH + saveFileName
	var file: FileAccess = FileAccess.open(filePath, FileAccess.WRITE)

	if file == null:
		push_error("Failed to open save file for writing: %s" % filePath)
		return

	var jsonString: String = JSON.stringify(currentSave)
	file.store_line(jsonString)
	file.close()

	gameSaved.emit()

# Loads all game data from a JSON file
func load_game() -> void:
	var filePath: String = SAVE_PATH + saveFileName

	if not FileAccess.file_exists(filePath):
		push_warning("Save file does not exist: %s" % filePath)
		return

	var file: FileAccess = FileAccess.open(filePath, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading: %s" % filePath)
		return

	var jsonText: String = file.get_line()
	file.close()

	var json := JSON.new()
	var parseErr: int = json.parse(jsonText)

	if parseErr != OK:
		push_error("Failed to parse save JSON: %s" % json.get_error_message())
		return

	var saveDict: Dictionary = json.get_data()

	if not (saveDict is Dictionary):
		push_error("Save file data corrupted — not a dictionary.")
		return

	currentSave = saveDict

	if currentSave.get("scene_path", "") == "":
		push_error("No valid scene path saved!")
		return

	LevelManager.loadNewLevel(
		currentSave.get("scene_path", ""),
		"",
		Vector2.ZERO
	)

	await LevelManager.level_load_initiated

	PlayerManager.set_player_position(Vector2(
		currentSave["player"].get("posX", 0.0),
		currentSave["player"].get("posY", 0.0)
	))

	PlayerManager.set_health(
		currentSave["player"].get("hp", 1),
		currentSave["player"].get("max_hp", 1)
	)

	PlayerManager.INVENTORY_DATA.parseSaveData(
		currentSave.get("items", [])
	)

	await LevelManager.level_load_completed

	gameLoaded.emit()

# Adds a persistent gameplay flag if it isn’t already present
func addPersistentValue(value: String) -> void:
	if not checkPersistentValue(value):
		currentSave["persistence"].append(value)

# Checks whether a persistent gameplay flag exists
func checkPersistentValue(value: String) -> bool:
	return currentSave.get("persistence", []).has(value)

# Updates the currentSave dictionary with player stats and position
func _updatePlayerData() -> void:
	var p: Node = PlayerManager.player

	if p:
		currentSave["player"]["hp"] = p.health
		currentSave["player"]["max_hp"] = p.maxHealth
		currentSave["player"]["posX"] = p.global_position.x
		currentSave["player"]["posY"] = p.global_position.y

# Stores the current scene path into the save dictionary
func _updateScenePath() -> void:
	currentSave["scene_path"] = LevelManager.currentScenePath

# Stores inventory data into the save dictionary
func _updateItemData() -> void:
	currentSave["items"] = PlayerManager.INVENTORY_DATA.getSaveData()

# Retrieves the save file if it exists
func get_save_file() -> FileAccess:
	var filePath: String = SAVE_PATH + saveFileName
	
	if not FileAccess.file_exists(filePath):
		return null
	
	var file := FileAccess.open(filePath, FileAccess.READ)
	return file
