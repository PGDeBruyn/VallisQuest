class_name HeartGUI
extends Control

@onready var sprite: Sprite2D = $Sprite2D

var value: int = 2:
	set(_value):
		value = _value
		updateSprite()

# Update the sprite frame based on the current value
func updateSprite() -> void:
	sprite.frame = value
