class_name PushableStatue
extends RigidBody2D

@export var pushSpeed: float = 30.0  # Speed at which the statue is pushed

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D  # Audio player for push sound

var pushDirection: Vector2 = Vector2.ZERO: set = setPush  # Direction of pushing, triggers audio play/stop on change

func _physics_process(_delta: float) -> void:
	# Apply velocity based on push direction and speed every physics frame
	linear_velocity = pushDirection * pushSpeed

func setPush(value: Vector2) -> void:
	# Setter for pushDirection, controls audio playback depending on movement
	pushDirection = value
	if pushDirection == Vector2.ZERO:
		audio.stop()
	else:
		audio.play()
