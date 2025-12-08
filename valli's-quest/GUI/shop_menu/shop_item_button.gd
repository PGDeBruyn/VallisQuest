class_name ShopItemButton
extends Button

var itemData: ItemData = null

func setupItem(_item: ItemData) -> void:
	# Assign the item data and update UI elements accordingly
	itemData = _item
	$Label.text = itemData.name
	$PriceLabel.text = str(itemData.cost)
	$TextureRect.texture = itemData.texture
