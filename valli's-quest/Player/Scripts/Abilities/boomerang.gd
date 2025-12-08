class_name Boomerang
extends Node2D

signal caught  # Emitted when the boomerang is caught by the player

# States the boomerang can be in
enum State {
	IDLE,
	LAUNCHED,
	RETURNING,
}

@export var max_speed: float = 400.0  # Maximum travel speed of the boomerang
@export var acceleration: float = 600.0  # Rate of acceleration/deceleration
@export var catch_sound: AudioStream  # Sound to play when catching the boomerang

var current_speed: float = 0.0  # Current speed of the boomerang
var direction: Vector2 = Vector2.ZERO  # Direction of travel
var state: int = State.IDLE  # Current state
var player: Player = null  # Reference to the player node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# Start invisible and get player reference
	visible = false
	player = PlayerManager.player

func _physics_process(delta: float) -> void:
	match state:
		State.LAUNCHED:
			# Decelerate while moving away from player
			current_speed = max(current_speed - acceleration * delta, 0)
			position += direction * current_speed * delta
			if current_speed <= 0:
				# When speed drops to zero, start returning
				state = State.RETURNING

		State.RETURNING:
			# Calculate direction back to player
			direction = (player.global_position - global_position).normalized()
			# Accelerate towards player up to max speed
			current_speed = min(current_speed + acceleration * delta, max_speed)
			position += direction * current_speed * delta

			# If close enough to player, catch the boomerang
			if global_position.distance_to(player.global_position) < 10:
				_catch()

		_:
			pass  # IDLE or other states do nothing

	_update_audio_and_animation()

func _update_audio_and_animation() -> void:
	# Adjust pitch and animation speed based on current speed ratio
	var speed_ratio = current_speed / max_speed if max_speed > 0 else 0.0
	audio_player.pitch_scale = lerp(0.75, 1.5, speed_ratio)
	animation_player.speed_scale = lerp(1.0, 1.25, speed_ratio)

func launch(launch_direction: Vector2) -> void:
	# Begin boomerang flight in a normalized direction with max speed
	direction = launch_direction.normalized()
	current_speed = max_speed
	state = State.LAUNCHED
	visible = true
	animation_player.play("boomerang")
	_play_catch_sound()

@onready var itemMagnet: ItemMagnet = $ItemMagnet

func _catch() -> void:
	# Stop boomerang and hide it upon catching
	state = State.IDLE
	visible = false
	_play_catch_sound()

	if itemMagnet:
		# Detach and re-enable physics for all items following the boomerang
		for item in itemMagnet.followingItems:
			if item is ItemPickup:
				itemMagnet.followingItems.erase(item)
				item.set_physics_process(true)
				# Reparent item back to main scene root if needed
				if item.get_parent() == itemMagnet:
					itemMagnet.remove_child(item)
					get_tree().get_root().add_child(item)

	# Emit caught signal and free the boomerang node
	emit_signal("caught")
	queue_free()

func _play_catch_sound() -> void:
	# Play catch sound if assigned
	if catch_sound:
		audio_player.stream = catch_sound
		audio_player.play()
