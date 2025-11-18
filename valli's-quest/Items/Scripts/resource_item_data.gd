class_name ItemData
extends Resource

signal item_used(success: bool)

@export var name: String = ""
@export_multiline var description: String = ""
@export var texture: Texture2D
@export_category("Effects")
@export var effects: Array[ItemEffect] = []

func can_use() -> bool:
	return effects.size() > 0

func use() -> bool:
	if not can_use():
		print("Cannot use: no effects")
		emit_signal("item_used", false)
		return false

	print("Using item effects, count:", effects.size())

	var index := 0
	while index < effects.size():
		var effect = effects[index]
		if effect != null:
			print("Using effect at index", index, "of type", effect)
			effect.use()
		else:
			print("Effect at index", index, "is null")
		index += 1

	emit_signal("item_used", true)
	return true
