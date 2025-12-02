@tool
extends Area2D
class_name LevelTransition

enum Side { LEFT, RIGHT, TOP, BOTTOM }

@export_file("*.tscn")
var nextLevel: String

@export var targetTransitionName: String = "LevelTransition"

@export var side = Side.LEFT: set = setSide
@export var size: int = 2: set = setSize

@export var snapToGrid: bool = true: set = setSnapToGrid
@export var centerPlayer: bool = false

@export_category("Editor Settings")
@export var gridSize: int = 16 # For snapping and offset distance

@onready var shape: CollisionShape2D = $CollisionShape2D

var canTransition: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		_updateCollisionArea()
		if snapToGrid:
			_snapToGrid()
		return

	monitoring = false
	_updateCollisionArea()

	if name == LevelManager.targetTransition:
		var safeOffset := _getSafeSpawnOffset()
		var newPos = global_position + LevelManager.positionOffset + safeOffset
		print("[LevelTransition] Setting player position to safe offset:", newPos)
		PlayerManager.set_player_position(newPos)
		await get_tree().process_frame  # Wait a frame to avoid immediate collision

	monitoring = true
	canTransition = false
	body_entered.connect(_onBodyEntered)

	# Increased cooldown to 0.5 seconds for safety
	get_tree().create_timer(0.5).connect("timeout", Callable(self, "_enableTransition"))

func _enableTransition() -> void:
	canTransition = true
	print("[LevelTransition] Transitions enabled on:", name)

func _onBodyEntered(body: Node) -> void:
	if not canTransition:
		return

	if LevelManager.ignoreTransitions:
		print("[LevelTransition] Ignoring transition due to LevelManager flag:", name)
		return

	# Prevent backtracking by ignoring the transition the player just came from
	if name == LevelManager.previousTransitionName:
		print("[LevelTransition] Ignoring backtracking on transition:", name)
		return

	if body.name != "Player":
		return

	print("[LevelTransition] Player entered transition:", name)
	var offset := _calculateOffset()
	LevelManager.loadNewLevel(nextLevel, targetTransitionName, offset)

func _getSafeSpawnOffset() -> Vector2:
	var safeOffset := Vector2.ZERO
	match side:
		Side.LEFT:
			safeOffset = Vector2(-gridSize * 2, 0)
		Side.RIGHT:
			safeOffset = Vector2(gridSize * 2, 0)
		Side.TOP:
			safeOffset = Vector2(0, -gridSize * 2)
		Side.BOTTOM:
			safeOffset = Vector2(0, gridSize * 2)
	return safeOffset

func _calculateOffset() -> Vector2:
	var offset := Vector2.ZERO
	var player := PlayerManager.player
	if player == null:
		return offset

	var playerPos := player.global_position
	match side:
		Side.LEFT:
			offset = Vector2(-gridSize, (playerPos.y - global_position.y) if not centerPlayer else 0)
		Side.RIGHT:
			offset = Vector2(gridSize, (playerPos.y - global_position.y) if not centerPlayer else 0)
		Side.TOP:
			offset = Vector2((playerPos.x - global_position.x) if not centerPlayer else 0, -gridSize)
		Side.BOTTOM:
			offset = Vector2((playerPos.x - global_position.x) if not centerPlayer else 0, gridSize)
	return offset

func _updateCollisionArea() -> void:
	if shape == null:
		return

	var rectSize := Vector2(32, 32)
	var rectOffset := Vector2.ZERO

	match side:
		Side.TOP:
			rectSize.x *= size
			rectOffset.y -= gridSize
		Side.BOTTOM:
			rectSize.x *= size
			rectOffset.y += gridSize
		Side.LEFT:
			rectSize.y *= size
			rectOffset.x -= gridSize
		Side.RIGHT:
			rectSize.y *= size
			rectOffset.x += gridSize

	if shape.shape:
		shape.shape.size = rectSize
	shape.position = rectOffset

func _snapToGrid() -> void:
	position = position.snapped(Vector2(gridSize, gridSize))

func setSide(value):
	side = value
	_updateCollisionArea()

func setSize(value):
	size = value
	_updateCollisionArea()

func setSnapToGrid(value):
	snapToGrid = value
	if snapToGrid:
		_snapToGrid()
