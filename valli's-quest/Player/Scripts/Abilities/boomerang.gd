class_name Boomerang
extends Node2D

signal caught

enum State {
	IDLE,
	LAUNCHED,
	RETURNING,
}

@export var max_speed: float = 400.0
@export var acceleration: float = 600.0
@export var catch_sound: AudioStream

var current_speed: float = 0.0
var direction: Vector2 = Vector2.ZERO
var state: int = State.IDLE
var player: Player = null

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	visible = false
	player = PlayerManager.player

func _physics_process(delta: float) -> void:
	match state:
		State.LAUNCHED:
			current_speed = max(current_speed - acceleration * delta, 0)
			position += direction * current_speed * delta
			if current_speed <= 0:
				state = State.RETURNING

		State.RETURNING:
			direction = (player.global_position - global_position).normalized()
			current_speed = min(current_speed + acceleration * delta, max_speed)
			position += direction * current_speed * delta

			if global_position.distance_to(player.global_position) < 10:
				_catch()

		_:
			pass

	_update_audio_and_animation()

func _update_audio_and_animation() -> void:
	var speed_ratio = current_speed / max_speed if max_speed > 0 else 0.0
	audio_player.pitch_scale = lerp(0.75, 1.5, speed_ratio)
	animation_player.speed_scale = lerp(1.0, 1.25, speed_ratio)

func launch(launch_direction: Vector2) -> void:
	direction = launch_direction.normalized()
	current_speed = max_speed
	state = State.LAUNCHED
	visible = true
	animation_player.play("boomerang")
	_play_catch_sound()

@onready var itemMagnet: ItemMagnet = $ItemMagnet

func _catch() -> void:
	state = State.IDLE
	visible = false
	_play_catch_sound()

	if itemMagnet:
		# Detach and re-enable physics for all following items
		for item in itemMagnet.followingItems:
			if item is ItemPickup:
				itemMagnet.followingItems.erase(item)
				item.set_physics_process(true)
				# Reparent back to main scene (adjust path as needed)
				if item.get_parent() == itemMagnet:
					itemMagnet.remove_child(item)
					get_tree().get_root().add_child(item)

	emit_signal("caught")
	queue_free()


func _play_catch_sound() -> void:
	if catch_sound:
		audio_player.stream = catch_sound
		audio_player.play()
