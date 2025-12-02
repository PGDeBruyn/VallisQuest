extends Node
class_name GlobalLevelManager

signal tilemap_bounds_updated(bounds: Array[Vector2])
signal level_load_initiated
signal level_load_completed

@onready var sceneTransition = _find_scene_transition()
# optional components
var tilemap_bounds: Array[Vector2] = []
var targetTransition: String = ""
var positionOffset: Vector2 = Vector2.ZERO
var currentScenePath: String = ""

func debug_print_state():
	if PlayerManager and PlayerManager.player:
		var p = PlayerManager.player
		if p.fsm and p.fsm.currentState:
			print("[DEBUG] Player state is:", p.fsm.currentState.name)
		else:
			print("[DEBUG] Player FSM or state is null")
	else:
		print("[DEBUG] PlayerManager or player is null")


func _find_scene_transition() -> Node:
	# safer lookup with debug
	if get_tree().root.has_node("SceneTransition"):
		var st = get_tree().root.get_node("SceneTransition")
		print("[LevelManager DEBUG] Found SceneTransition node at root.")
		return st
	# try alternative common locations
	if get_tree().current_scene and get_tree().current_scene.has_node("SceneTransition"):
		var st2 = get_tree().current_scene.get_node("SceneTransition")
		print("[LevelManager DEBUG] Found SceneTransition in current_scene.")
		return st2
	print("[LevelManager DEBUG] SceneTransition not found; using timers as fallback.")
	return null

func _ready() -> void:
	await get_tree().process_frame

	if currentScenePath == "":
		var current_scene = get_tree().current_scene
		if current_scene != null:
			var path = current_scene.get_scene_file_path()
			if path != "":
				currentScenePath = path
				print("[LevelManager DEBUG] Set currentScenePath on ready: %s" % currentScenePath)

	emit_signal("level_load_completed")
	print("[LevelManager DEBUG] ready complete")


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
	print("[LevelManager DEBUG] emitted level_load_initiated")
	await get_tree().process_frame

	var err = get_tree().change_scene_to_file(levelPath)
	if err != OK:
		push_error("Failed to load level: %s" % levelPath)
	else:
		# Confirm path after successful load
		currentScenePath = levelPath
		print("[LevelManager DEBUG] Loaded scene: %s" % currentScenePath)

	await get_tree().process_frame
	await _fade_in()

	print("[LevelManager DEBUG] after fade_in — unpausing tree")
	get_tree().paused = false
	print("[LevelManager DEBUG] get_tree().paused = %s" % str(get_tree().paused))
	await get_tree().process_frame

	emit_signal("level_load_completed")
	print("[LevelManager DEBUG] emitted level_load_completed")


func _fade_out() -> void:
	if _is_player_dead():
		print("[LevelManager DEBUG] Player dead — skipping fadeOut()")
		await get_tree().process_frame
		return

	if sceneTransition:
		await sceneTransition.fadeOut()
	else:
		await get_tree().create_timer(0.4).timeout


func _fade_in() -> void:
	if _is_player_dead():
		print("[LevelManager DEBUG] Player dead — skipping fadeIn()")
		return

	if sceneTransition:
		await sceneTransition.fadeIn()
	else:
		await get_tree().create_timer(0.4).timeout



func reset() -> void:
	print("[LevelManager DEBUG] LevelManager reset")
	currentScenePath = ""
	targetTransition = ""
	positionOffset = Vector2.ZERO




func _is_player_dead() -> bool:
	if PlayerManager and PlayerManager.player:
		var p = PlayerManager.player
		if p.fsm and p.fsm.currentState:
			return p.fsm.currentState.name == "Death"
	return false
