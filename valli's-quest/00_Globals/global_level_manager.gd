extends Node
class_name GlobalLevelManager

signal tilemap_bounds_updated(bounds: Array[Vector2])
signal level_load_initiated
signal level_load_completed

@onready var sceneTransition = get_tree().root.get_node("SceneTransition") # optional

var tilemap_bounds: Array[Vector2] = []
var targetTransition: String = ""
var positionOffset: Vector2 = Vector2.ZERO
var currentScenePath: String = ""

func _ready() -> void:
	await get_tree().process_frame

	if currentScenePath == "":
		var current_scene = get_tree().current_scene
		if current_scene != null:
			var path = current_scene.get_scene_file_path()
			if path != "":
				currentScenePath = path
				print("LevelManager: Set currentScenePath on ready:", currentScenePath)

	emit_signal("level_load_completed")


func set_tilemap_bounds(bounds: Array[Vector2]) -> void:
	tilemap_bounds = bounds
	emit_signal("tilemap_bounds_updated", bounds)

func loadNewLevel(levelPath: String, _targetTransition: String, _positionOffset: Vector2) -> void:
	currentScenePath = levelPath  # Set early to avoid empty path issues
	get_tree().paused = true
	targetTransition = _targetTransition
	positionOffset = _positionOffset

	await _fade_out()
	emit_signal("level_load_initiated")
	await get_tree().process_frame

	var err = get_tree().change_scene_to_file(levelPath)
	if err != OK:
		push_error("Failed to load level: %s" % levelPath)
	else:
		# Confirm path after successful load
		currentScenePath = levelPath
		print("Loaded scene:", currentScenePath)

	await get_tree().process_frame
	await _fade_in()

	get_tree().paused = false
	await get_tree().process_frame

	emit_signal("level_load_completed")

func _fade_out() -> void:
	if sceneTransition:
		await sceneTransition.fadeOut()
	else:
		await get_tree().create_timer(0.4).timeout

func _fade_in() -> void:
	if sceneTransition:
		await sceneTransition.fadeIn()
	else:
		await get_tree().create_timer(0.4).timeout
