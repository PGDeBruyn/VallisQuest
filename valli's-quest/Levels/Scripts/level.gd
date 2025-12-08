extends Node2D
class_name LevelArea

@export var backgroundMusic: AudioStream
var initialized := false


func _enter_tree() -> void:
	# Ensure y-sorting is set immediately when added to tree
	y_sort_enabled = true
	
	# Safely reparent the player to this level
	if Engine.is_editor_hint():
		return
	_reparentPlayerToLevel()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Use call_deferred to ensure everything else (like signals) is ready
	call_deferred("_initializeLevel")


func _initializeLevel() -> void:
	if initialized:
		return

	# Connect to the level load signal once (use weakref so we don't leak signals)
	if LevelManager:
		LevelManager.level_load_initiated.connect(_onLevelLoadInitiated, CONNECT_ONE_SHOT)

	# Start background music safely
	if AudioManager and backgroundMusic:
		AudioManager.playMusic(backgroundMusic)
	initialized = true


func _onLevelLoadInitiated() -> void:
	# When a new level is being loaded, this one cleans itself up
	if PlayerManager:
		PlayerManager.unparent_player()
	queue_free()


func _reparentPlayerToLevel() -> void:
	# Ensure player exists before reparenting
	if PlayerManager:
		var player = PlayerManager.get_player()
		if player:
			PlayerManager.reparentPlayer(self)
		else:
			# Player not spawned yet — delay reparent
			await get_tree().process_frame
			PlayerManager.reparentPlayer(self)
