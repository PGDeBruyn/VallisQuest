class_name Hitbox extends Area2D

signal damaged(damage: int)

func takeDamage(hurtbox: Hurtbox) -> void:
	emit_signal("damaged", hurtbox)
