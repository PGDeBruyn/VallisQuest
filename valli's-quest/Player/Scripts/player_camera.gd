class_name PlayerCamera
extends Camera2D

var bounds_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)  # Stores the rectangular bounds of the level's tilemap

func _ready():
	# Called when the node is added to the scene
	# Debug prints to verify LevelManager availability and its signals
	print("LevelManager:", LevelManager)
	print("Signals:", LevelManager.get_signal_list())
	
	# Connect to LevelManager's signal that notifies when tilemap bounds change
	LevelManager.tilemap_bounds_updated.connect(_onTileMapBoundsChanged)
	
	# Initialize camera limits based on current tilemap bounds
	_onTileMapBoundsChanged(LevelManager.tilemap_bounds)

func _onTileMapBoundsChanged(bounds: Array[Vector2]) -> void:
	# Called when tilemap bounds update signal is emitted
	# bounds is expected to be an Array with two Vector2 elements: [top-left, bottom-right]
	if bounds.is_empty():
		# If no bounds provided, do nothing
		return

	# Calculate the Rect2 from the two bounds points
	bounds_rect = Rect2(bounds[0], bounds[1] - bounds[0])

	# Update camera limits based on new bounds rectangle
	_updateLimits()

func _updateLimits() -> void:
	# Update the camera's limit properties so the camera stays within the tilemap bounds
	limit_left = int(bounds_rect.position.x)
	limit_top = int(bounds_rect.position.y)
	limit_right = int(bounds_rect.position.x + bounds_rect.size.x)
	limit_bottom = int(bounds_rect.position.y + bounds_rect.size.y)
