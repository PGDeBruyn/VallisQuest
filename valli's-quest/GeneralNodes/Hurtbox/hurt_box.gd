class_name Hurtbox
extends Area2D

@export var damage: int = 1

func _ready():
	area_entered.connect(Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		area.takeDamage(self)
