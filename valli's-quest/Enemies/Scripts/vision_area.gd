class_name VisionArea
extends Area2D

signal player_spotted
signal player_lost

var enemy_ref: Node = null

var direction_angles := {
	Vector2.DOWN: 0,
	Vector2.UP: 180,
	Vector2.LEFT: 90,
	Vector2.RIGHT: -90
}

# Connects signals and initializes enemy reference and rotation.
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	enemy_ref = get_parent()
	if enemy_ref and enemy_ref.has_signal("directionChanged"):
		enemy_ref.connect("directionChanged", Callable(self, "_on_direction_changed"))

	_on_direction_changed(Vector2.DOWN)  # default rotation

# Emits player_spotted signal when player enters area.
func _on_body_entered(body: Node) -> void:
	if body is Player:
		emit_signal("player_spotted")

# Emits player_lost signal when player exits area.
func _on_body_exited(body: Node) -> void:
	if body is Player:
		emit_signal("player_lost")

# Updates rotation based on enemy's facing direction.
func _on_direction_changed(new_dir: Vector2) -> void:
	if new_dir == Vector2.ZERO:
		return

	var closest_dir := Vector2.DOWN
	var max_dot := -1.0
	for dir in direction_angles.keys():
		var dot := new_dir.normalized().dot(dir)
		if dot > max_dot:
			max_dot = dot
			closest_dir = dir

	var target_angle = direction_angles[closest_dir]
	rotation_degrees = target_angle  # Instant set, no lerp
