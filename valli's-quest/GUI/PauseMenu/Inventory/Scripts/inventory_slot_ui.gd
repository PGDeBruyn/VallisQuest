class_name InventorySlotUI
extends Button

var slotData: SlotData = null
var pause_menu: PauseMenu  # Must be assigned externally

@onready var textureRect: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var item_description: Label = $"../../../ItemDescription"  # Confirm path is correct in your scene

func _ready() -> void:
	_clearUI()
	connect("pressed", Callable(self, "_on_pressed"))

# Called externally to set or update this slot's data
func set_slot_data(value: SlotData) -> void:
	slotData = value
	_updateUI()

func _clearUI() -> void:
	textureRect.texture = null
	label.text = ""
	# Keep focus mode consistent for keyboard/controller navigation
	focus_mode = Control.FOCUS_ALL
	modulate = Color(1, 1, 1, 1)  # Reset any color modulation

func _updateUI() -> void:
	if slotData == null or slotData.itemData == null:
		_clearUI()
		return

	textureRect.texture = slotData.itemData.texture
	label.text = str(slotData.quantity)

	focus_mode = Control.FOCUS_ALL  # Always allow focus for navigation

	if not slotData.itemData.can_use():
		# Optional: visually gray out unusable items
		# modulate = Color(0.6, 0.6, 0.6, 1)
		pass
	else:
		modulate = Color(1, 1, 1, 1)  # Normal coloring for usable items

# Signal handlers to update description when slot is focused/unfocused
func _on_focus_entered() -> void:
	if slotData and slotData.itemData and pause_menu:
		pause_menu.updateItemDescription(slotData.itemData.description)

func _on_focus_exited() -> void:
	if pause_menu:
		pause_menu.updateItemDescription("")

# Called when the slot button is pressed
func _on_pressed() -> void:
	print("Slot pressed!")
	
	if slotData == null or slotData.itemData == null:
		print("Invalid slot or item")
		return

	if not slotData.itemData.can_use():
		print("Item cannot be used")
		# Optional: play error sound or show feedback here
		return

	var inventory := PlayerManager.INVENTORY_DATA
	if inventory == null:
		print("Inventory is null!")
		return

	if inventory.useItem(slotData.itemData, 1):
		print("Item used successfully")
		_updateUI()
	else:
		print("Failed to use item")
