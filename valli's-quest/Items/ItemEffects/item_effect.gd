class_name ItemEffect
extends Resource

@export var useDescription: String = ""

signal effectApplied(success: bool)

func use() -> void:
	# Notify subclasses to implement effect logic by emitting a signal they can listen for
	emit_signal("effectApplied", false)
