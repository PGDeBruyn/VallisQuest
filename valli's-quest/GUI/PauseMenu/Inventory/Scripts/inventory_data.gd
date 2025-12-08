class_name InventoryData
extends Resource

@export var slots: Array[SlotData] = []

signal inventory_changed

# Called on creation, connects signals for existing slots
func _init() -> void:
	connectSlots()

# Adds an item to inventory; tries stacking first, then empty slot
# Returns true if item added successfully, false if inventory full
func addItem(item: ItemData, count: int = 1) -> bool:
	print("Adding item: ", item, " count: ", count)
	# Try stacking existing slots with same item
	for s in slots:
		if s != null and s.itemData == item:
			s.quantity += count
			print("Stacked item. New qty: ", s.quantity)
			emit_signal("inventory_changed")
			return true
	
	# Try to add new slot if empty slot found
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

# Connects the changed signal on all existing non-null slots
func connectSlots() -> void:
	for s in slots:
		if s != null:
			s.changed.connect(slotChanged)

# Called when a slot changes; removes slots with zero quantity and emits signal
func slotChanged() -> void:
	for s in slots:
		if s != null:
			if s.quantity < 1:
				s.changed.disconnect(slotChanged)
				var index: int = slots.find(s)
				slots[index] = null
				emit_signal("inventory_changed")

# Returns an array of dictionaries suitable for saving the inventory state
func getSaveData() -> Array:
	var itemSave: Array = []
	for s in slots:
		itemSave.append(itemToSave(s))
	return itemSave

# Converts a slot to a dictionary for saving
func itemToSave(slot: SlotData) -> Dictionary:
	var result: Dictionary = {"item": "", "quantity": 0}
	if slot != null:
		result["quantity"] = slot.quantity
		if slot.itemData != null:
			result["item"] = slot.itemData.resource_path
	return result

# Loads inventory data from a saved array of dictionaries
func parseSaveData(saveData: Array) -> void:
	var size: int = slots.size()
	slots.clear()
	slots.resize(size)

	for i in range(saveData.size()):
		var sData: Dictionary = saveData[i]
		slots[i] = itemFromSave(sData)

	connectSlots()

# Creates a SlotData from a save dictionary; returns null if invalid
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

# Uses a specified number of items; returns true if used successfully, false otherwise
func useItem(item: ItemData, count: int = 1) -> bool:
	if item == null:
		return false

	var remaining: int = count
	var itemPath: String = item.resource_path

	for slot in slots:
		if slot != null and slot.itemData != null and slot.quantity > 0:
			if slot.itemData.resource_path == itemPath:
				var used: int = min(slot.quantity, remaining)

				slot.itemData.use()  # Trigger the item's effect
				slot.quantity -= used
				remaining -= used

				if slot.quantity <= 0:
					slot.itemData = null
					slot.quantity = 0

				if remaining <= 0:
					emit_signal("inventory_changed")
					return true

	# Not enough quantity available to fulfill use request
	return false

# Returns the total quantity held of the specified item across all slots
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
