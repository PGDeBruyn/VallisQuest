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
	# Editor setup: update collision shape and optionally snap position to grid
	if Engine.is_editor_hint():
		_updateCollisionArea()
		if snapToGrid:
			_snapToGrid()
		return

	# Gameplay setup: disable monitoring initially and update collision shape
	monitoring = false
	_updateCollisionArea()

	# Position player if this transition is the target after level load
	if name == LevelManager.targetTransition:
		var safeOffset := _getSafeSpawnOffset()
		var newPos = global_position + LevelManager.positionOffset + safeOffset
		print("[LevelTransition] Setting player position to safe offset:", newPos)
		PlayerManager.set_player_position(newPos)
		await get_tree().process_frame  # Delay one frame to avoid immediate collision

	monitoring = true
	canTransition = false
	body_entered.connect(_onBodyEntered)

	# Delay enabling transitions to prevent instant retriggering
	get_tree().create_timer(0.5).connect("timeout", Callable(self, "_enableTransition"))

func _enableTransition() -> void:
	# Allow the transition to trigger after cooldown
	canTransition = true
	print("[LevelTransition] Transitions enabled on:", name)

func _onBodyEntered(body: Node) -> void:
	# Ignore if transitions are not enabled or if globally ignored
	if not canTransition:
		return

	if LevelManager.ignoreTransitions:
		print("[LevelTransition] Ignoring transition due to LevelManager flag:", name)
		return

	# Prevent backtracking through the previous transition
	if name == LevelManager.previousTransitionName:
		print("[LevelTransition] Ignoring backtracking on transition:", name)
		return

	# Only react if the player entered
	if body.name != "Player":
		return

	print("[LevelTransition] Player entered transition:", name)
	var offset := _calculateOffset()
	LevelManager.loadNewLevel(nextLevel, targetTransitionName, offset)

func _getSafeSpawnOffset() -> Vector2:
	# Provides a safe offset vector based on the side of the transition to position the player
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
	# Calculates the offset to apply when loading the next level, optionally centering the player
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
	# Updates the size and position of the collision shape based on the transition side and size
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
	# Snaps the node's position to the configured grid size
	position = position.snapped(Vector2(gridSize, gridSize))

func setSide(value):
	# Setter for the side property, updates collision area accordingly
	side = value
	_updateCollisionArea()

func setSize(value):
	# Setter for the size property, updates collision area accordingly
	size = value
	_updateCollisionArea()

func setSnapToGrid(value):
	# Setter for snapToGrid property, snaps to grid if enabled
	snapToGrid = value
	if snapToGrid:
		_snapToGrid()
