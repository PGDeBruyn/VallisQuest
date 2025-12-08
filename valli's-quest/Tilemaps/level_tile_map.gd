extends TileMap
class_name LevelTileMap

@export var useCustomQuadrantSize: bool = false
@export var quadrantSize: Vector2 = Vector2(16, 16)  # Custom cell size if enabled
@export var autoReportBounds: bool = true  # Whether to automatically send bounds to LevelManager

# Cached bounds: [top-left, bottom-right] in global coordinates
var mapBounds: Array[Vector2] = []

func _ready() -> void:
	# Delay initialization to ensure tiles are loaded
	call_deferred("_initialize_tilemap")

func _initialize_tilemap() -> void:
	mapBounds = _calculate_tilemap_bounds()

	if autoReportBounds and Engine.has_singleton("LevelManager"):
		var manager = Engine.get_singleton("LevelManager")
		if manager:
			manager.set_tilemap_bounds(mapBounds)
	else:
		push_warning("LevelTileMap: Could not report bounds (LevelManager missing or autoReportBounds disabled).")

func _calculate_tilemap_bounds() -> Array[Vector2]:
	var used_rect := get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		push_warning("LevelTileMap: No tiles detected in TileMap.")
		return [Vector2.ZERO, Vector2.ZERO]

	# Determine cell size vector
	var cell_size_vec: Vector2
	if useCustomQuadrantSize:
		cell_size_vec = quadrantSize
	elif tile_set:
		cell_size_vec = Vector2(tile_set.tile_size)
	else:
		push_warning("LevelTileMap: No TileSet found — defaulting cell size to (16, 16).")
		cell_size_vec = Vector2(16, 16)

	# Calculate top-left and bottom-right corners in world space
	var top_left := Vector2(used_rect.position) * cell_size_vec
	var bottom_right := Vector2(used_rect.position + used_rect.size) * cell_size_vec

	return [top_left, bottom_right]

func get_tilemap_bounds() -> Array[Vector2]:
	return mapBounds

func print_bounds() -> void:
	if mapBounds.size() == 2:
		print("TileMap Bounds → TopLeft:", mapBounds[0], "| BottomRight:", mapBounds[1])
	else:
		print("TileMap Bounds not yet calculated.")
