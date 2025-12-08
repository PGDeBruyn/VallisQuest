class_name ItemData
extends Resource

signal item_used(success: bool)

@export var name: String = ""
@export_multiline var description: String = ""
@export var texture: Texture2D
@export var cost: int = 10
@export_category("Effects")
@export var effects: Array[ItemEffect] = []

func can_use() -> bool:
	# Returns true if this item has one or more effects to use
	return effects.size() > 0

func use() -> bool:
	# Attempts to use the item and its effects; returns success status
	if not can_use():
		print("Cannot use: no effects")
		item_used.emit(false)
		return false

	print("Using item effects, count:", effects.size())

	for i in effects.size():
		var effect = effects[i]
		if effect != null:
			print("Using effect at index", i, "of type", effect)
			effect.use()
		else:
			print("Effect at index", i, "is null")

	item_used.emit(true)
	return true
