class_name PlayerCamera
extends Camera2D

var bounds_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

func _ready():
	# Debug prints
	print("LevelManager:", LevelManager)
	print("Signals:", LevelManager.get_signal_list())
	
	LevelManager.tilemap_bounds_updated.connect(_onTileMapBoundsChanged)
	_onTileMapBoundsChanged(LevelManager.tilemap_bounds)

func _onTileMapBoundsChanged(bounds: Array[Vector2]) -> void:
	if bounds.is_empty():
		return
	bounds_rect = Rect2(bounds[0], bounds[1] - bounds[0])
	_updateLimits()

func _updateLimits() -> void:
	limit_left = int(bounds_rect.position.x)
	limit_top = int(bounds_rect.position.y)
	limit_right = int(bounds_rect.position.x + bounds_rect.size.x)
	limit_bottom = int(bounds_rect.position.y + bounds_rect.size.y)
