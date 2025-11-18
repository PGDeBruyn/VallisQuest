class_name InventorySlotUI
extends Button

var slotData: SlotData = null
var pause_menu: PauseMenu  # Must be assigned externally

@onready var textureRect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	_clearUI()
	connect("pressed", Callable(self, "_on_pressed"))

# Called externally to update this slot's data
func set_slot_data(value: SlotData) -> void:
	slotData = value
	_updateUI()

func _clearUI() -> void:
	textureRect.texture = null
	label.text = ""

func _updateUI() -> void:
	if slotData == null or slotData.itemData == null:
		_clearUI()
		return

	textureRect.texture = slotData.itemData.texture
	label.text = str(slotData.quantity)

# These three functions should be connected via the Godot editor signals panel:
func _on_focus_entered() -> void:
	if slotData and slotData.itemData and pause_menu:
		pause_menu.update_item_description(slotData.itemData.description)

func _on_focus_exited() -> void:
	if pause_menu:
		pause_menu.update_item_description("")

func _on_pressed() -> void:
	print("Slot pressed!")
	if slotData == null:
		print("slotData is null")
		return
	if slotData.itemData == null:
		print("slotData.itemData is null")
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
