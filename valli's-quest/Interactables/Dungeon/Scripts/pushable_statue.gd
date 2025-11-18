class_name PushableStatue extends RigidBody2D

@export var pushSpeed: float = 30.0

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var pushDirection: Vector2 = Vector2.ZERO: set = setPush


func _physics_process(_delta: float) -> void:
	linear_velocity = pushDirection * pushSpeed

func setPush(value: Vector2) -> void:
	pushDirection = value
	if pushDirection == Vector2.ZERO:
		audio.stop()
	else:
		audio.play()
