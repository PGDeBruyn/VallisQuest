@tool
extends Area2D
class_name LevelTransition

enum Side { LEFT, RIGHT, TOP, BOTTOM }

@export_file("*.tscn") var nextLevel: String
@export var targetTransitionName: String = "LevelTransition"

@export var side = Side.LEFT:
	set(value):
		side = value
		_updateCollisionArea()

@export var size: int = 2:
	set(value):
		size = value
		_updateCollisionArea()

@export var snapToGrid: bool = true:
	set(value):
		snapToGrid = value
		if snapToGrid:
			_snapToGrid()

@export var centerPlayer: bool = false

@export_category("Editor Settings")
@export var gridSize: int = 16  # For snapping and offset distance

@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if Engine.is_editor_hint():
		_updateCollisionArea()
		if snapToGrid:
			_snapToGrid()
		return

	monitoring = false
	_updateCollisionArea()

	if name == LevelManager.targetTransition:
		PlayerManager.set_player_position(global_position + LevelManager.positionOffset)

	await LevelManager.level_load_completed
	monitoring = true

	body_entered.connect(_onBodyEntered)

func _onBodyEntered(body: Node) -> void:
	if body.name != "Player":
		return

	var offset := _calculateOffset()
	LevelManager.loadNewLevel(nextLevel, targetTransitionName, offset)

func _calculateOffset() -> Vector2:
	var offset := Vector2.ZERO
	var player := PlayerManager.player

	if player == null:
		return offset

	var playerPos := player.global_position

	match side:
		Side.LEFT:
			offset = Vector2(-gridSize, playerPos.y - global_position.y if not centerPlayer else 0)
		Side.RIGHT:
			offset = Vector2(gridSize, playerPos.y - global_position.y if not centerPlayer else 0)
		Side.TOP:
			offset = Vector2(playerPos.x - global_position.x if not centerPlayer else 0, -gridSize)
		Side.BOTTOM:
			offset = Vector2(playerPos.x - global_position.x if not centerPlayer else 0, gridSize)

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
