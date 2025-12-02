class_name InventoryData
extends Resource

@export var slots: Array[SlotData] = []

signal inventory_changed

func _init() -> void:
	connectSlots()

func addItem(item: ItemData, count: int = 1) -> bool:
	print("Adding item: ", item, " count: ", count)
	for s in slots:
		if s != null and s.itemData == item:
			s.quantity += count
			print("Stacked item. New qty: ", s.quantity)
			emit_signal("inventory_changed")
			return true
	
	for i in range(slots.size()):
		if slots[i] == null:
			var newSlot = SlotData.new()
			newSlot.itemData = item
			newSlot.quantity = count
			slots[i] = newSlot
			newSlot.changed.connect(slotChanged)
			print("Added new slot at index ", i)
			emit_signal("inventory_changed")
			return true
	
	print("Inventory full. Cannot add item.")
	return false


func connectSlots() -> void:
	for s in slots:
		if s != null:
			s.changed.connect(slotChanged)

func slotChanged() -> void:
	for s in slots:
		if s != null:
			if s.quantity < 1:
				s.changed.disconnect(slotChanged)
				var index: int = slots.find(s)
				slots[index] = null
				emit_signal("inventory_changed")

func getSaveData() -> Array:
	var itemSave: Array = []
	for s in slots:
		itemSave.append(itemToSave(s))
	return itemSave

func itemToSave(slot: SlotData) -> Dictionary:
	var result: Dictionary = {"item": "", "quantity": 0}
	if slot != null:
		result["quantity"] = slot.quantity
		if slot.itemData != null:
			result["item"] = slot.itemData.resource_path
	return result

func parseSaveData(saveData: Array) -> void:
	var size: int = slots.size()
	slots.clear()
	slots.resize(size)

	for i in range(saveData.size()):
		var sData: Dictionary = saveData[i]
		slots[i] = itemFromSave(sData)

	connectSlots()

func itemFromSave(saveObject: Dictionary) -> SlotData:
	if not saveObject.has("item") or saveObject["item"] == "":
		return null

	var itemRes: Resource = load(saveObject["item"])
	if itemRes == null:
		return null

	var slot: SlotData = SlotData.new()
	slot.itemData = itemRes
	slot.quantity = int(saveObject.get("quantity", 0))
	return slot

func useItem(item: ItemData, count: int = 1) -> bool:
	if item == null:
		return false

	var remaining: int = count
	var itemPath: String = item.resource_path

	for slot in slots:
		if slot != null and slot.itemData != null and slot.quantity > 0:
			if slot.itemData.resource_path == itemPath:
				var used: int = min(slot.quantity, remaining)

				slot.itemData.use()  # Call item effect
				slot.quantity -= used
				remaining -= used

				if slot.quantity <= 0:
					slot.itemData = null
					slot.quantity = 0

				if remaining <= 0:
					emit_signal("inventory_changed")
					return true

	# Not enough quantity found
	return false

func get_item_held_qty(item: ItemData) -> int:
	if item == null:
		return 0

	var total: int = 0
	var itemPath: String = item.resource_path

	for slot in slots:
		if slot != null and slot.itemData != null:
			if slot.itemData.resource_path == itemPath:
				total += slot.quantity

	return total
