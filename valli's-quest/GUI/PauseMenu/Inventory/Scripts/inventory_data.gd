class_name InventoryData
extends Resource

@export var slots: Array[SlotData] = []

signal inventory_changed

func addItem(item: ItemData, count: int = 1) -> bool:
	var emptySlotIndex = -1
	
	for i in range(slots.size()):
		var slot = slots[i]
		if slot != null and slot.itemData == item:
			slot.quantity += count
			emit_signal("inventory_changed")
			return true
		elif slot == null and emptySlotIndex == -1:
			emptySlotIndex = i
	
	if emptySlotIndex != -1:
		var newSlot = SlotData.new()
		newSlot.itemData = item
		newSlot.quantity = count
		slots[emptySlotIndex] = newSlot
		emit_signal("inventory_changed")
		return true
	
	return false


func getSaveData() -> Array:
	var saveArray = []
	
	for slot in slots:
		if slot == null:
			continue
		if slot.itemData == null:
			continue
		if slot.quantity <= 0:
			continue
		
		# Add slot data dictionary
		saveArray.append({
			"item": slot.itemData.resource_path,
			"quantity": slot.quantity
		})
	
	return saveArray


func itemToSave(slot: SlotData) -> Dictionary:
	var saveDict = {"item": "", "quantity": 0}
	
	if slot == null:
		return saveDict
	
	if slot.itemData == null:
		return saveDict
	
	# If everything is valid, update dictionary
	saveDict["item"] = slot.itemData.resource_path
	saveDict["quantity"] = slot.quantity
	
	return saveDict


func parseSaveData(saveData: Array) -> void:
	var desiredSize = max(slots.size(), saveData.size())
	
	slots.resize(desiredSize)
	for i in range(slots.size()):
		slots[i] = null
	
	for i in range(saveData.size()):
		var data = saveData[i]
		if data.has("item") and data.has("quantity") and data["item"] != "":
			var newSlot = SlotData.new()
			newSlot.itemData = load(data["item"])
			newSlot.quantity = int(data["quantity"])
			slots[i] = newSlot
	
	emit_signal("inventory_changed")



func itemFromSave(saveObject: Dictionary) -> SlotData:
	var itemPath = saveObject.get("item", "")
	assert(itemPath != "", "itemFromSave: 'item' path cannot be empty")

	var itemRes = ResourceLoader.load(itemPath)
	assert(itemRes != null, "itemFromSave: Failed to load resource at '%s'" % itemPath)

	var slot = SlotData.new()
	slot.itemData = itemRes
	slot.quantity = int(saveObject.get("quantity", 0))
	return slot


func useItem(item: ItemData, count: int = 1) -> bool:
	print("useItem being called")
	var remaining = count
	var itemPath = item.resource_path  # Use path for comparison

	for slot in slots:
		if slot != null and slot.itemData != null and slot.quantity > 0:
			if slot.itemData.resource_path == itemPath:
				var used = min(slot.quantity, remaining)
				print("Using item:", slot.itemData.name, " Quantity in slot:", slot.quantity)

				slot.itemData.use()  # Call effects
				slot.quantity -= used
				remaining -= used

				if slot.quantity <= 0:
					# Clear empty slot
					slot.itemData = null
					slot.quantity = 0

				if remaining <= 0:
					emit_signal("inventory_changed")
					return true
	# Not enough quantity found
	return false
