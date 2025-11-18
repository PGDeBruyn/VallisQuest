class_name HeartGUI
extends Control

@onready var sprite: Sprite2D = $Sprite2D

var _value: int = 2

func set_value(new_val: int) -> void:
	_value = clamp(new_val, 0, 2)
	sprite.frame = _value
