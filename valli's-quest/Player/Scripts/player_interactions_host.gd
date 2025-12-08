class_name PlayerInteractionHost
extends Node2D

# Enum representing possible facing directions
enum Directions {
	DOWN,
	UP,
	LEFT,
	RIGHT,
	UNKNOWN
}

@onready var playerRef: Player = get_parent()  # Reference to the Player node (assumed to be the parent)
var currentFacing: Directions = Directions.UNKNOWN  # Tracks current facing direction to detect changes

func _process(_delta: float) -> void:
	# Called every frame; updates the rotation based on player's facing direction
	
	if playerRef == null:
		# Safety check if player reference is missing
		return
	
	var facingVec := playerRef.facing  # Get player's facing as a Vector2
	var facingDir := _vectorToDirection(facingVec)  # Convert vector to one of the Directions enum
	
	# Only update if facing direction changed since last frame
	if facingDir != currentFacing:
		currentFacing = facingDir
		_applyRotationForFacing(facingDir)  # Rotate this node to match player's facing

func _vectorToDirection(vec: Vector2) -> Directions:
	# Converts a Vector2 facing to the Directions enum
	if vec == Vector2.DOWN:
		return Directions.DOWN
	elif vec == Vector2.UP:
		return Directions.UP
	elif vec == Vector2.LEFT:
		return Directions.LEFT
	elif vec == Vector2.RIGHT:
		return Directions.RIGHT
	return Directions.UNKNOWN  # If none match exactly, return UNKNOWN

func _applyRotationForFacing(dir: Directions) -> void:
	# Rotates this node based on the facing direction
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
			rotation_degrees = 0  # Default fallback
