class_name Hurtbox
extends Area2D

@export var damage: int = 1

# Connects signal to detect when another area enters this hurtbox.
func _ready():
	area_entered.connect(Callable(self, "_on_area_entered"))

# Calls takeDamage on any Hitbox that enters this hurtbox.
func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		area.takeDamage(self)
