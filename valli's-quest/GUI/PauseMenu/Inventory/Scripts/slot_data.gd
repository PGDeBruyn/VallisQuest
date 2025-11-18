class_name SlotData
extends Resource

@export var itemData: ItemData
@export var quantity: int = 0

func setQuantity(value: int) -> void:
	quantity = max(value, 0)
	emit_changed()
