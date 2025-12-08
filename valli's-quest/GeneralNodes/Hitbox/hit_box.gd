class_name Hitbox
extends Area2D

signal damaged(damage: int)

# Emits a damaged signal when hit by a Hurtbox.
func takeDamage(hurtbox: Hurtbox) -> void:
	emit_signal("damaged", hurtbox)
