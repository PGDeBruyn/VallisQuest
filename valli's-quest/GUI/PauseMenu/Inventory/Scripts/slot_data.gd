class_name SlotData
extends Resource

@export var itemData: ItemData
@export var quantity: int = 0

# Set the quantity ensuring it never goes below zero and notify listeners of the change
func setQuantity(value: int) -> void:
	quantity = max(value, 0)
	emit_changed()
