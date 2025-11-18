class_name PlayerInteractionHost extends Node2D

enum Directions {
	DOWN,
	UP,
	LEFT,
	RIGHT,
	UNKNOWN
}

@onready var playerRef: Player = get_parent()
var currentFacing: Directions = Directions.UNKNOWN

func _process(_delta: float) -> void:
	if playerRef == null:
		return
	
	var facingVec := playerRef.facing
	var facingDir := _vectorToDirection(facingVec)
	
	if facingDir != currentFacing:
		currentFacing = facingDir
		_applyRotationForFacing(facingDir)

func _vectorToDirection(vec: Vector2) -> Directions:
	if vec == Vector2.DOWN:
		return Directions.DOWN
	elif vec == Vector2.UP:
		return Directions.UP
	elif vec == Vector2.LEFT:
		return Directions.LEFT
	elif vec == Vector2.RIGHT:
		return Directions.RIGHT
	return Directions.UNKNOWN

func _applyRotationForFacing(dir: Directions) -> void:
	match dir:
		Directions.UP:
			rotation_degrees = 180
		Directions.LEFT:
			rotation_degrees = 90
		Directions.RIGHT:
			rotation_degrees = -90
		Directions.DOWN:
			rotation_degrees = 0
		_:
			rotation_degrees = 0
