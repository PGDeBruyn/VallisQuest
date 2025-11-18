class_name InventoryUI
extends Control

const INVENTORY_SLOT = preload("res://GUI/PauseMenu/Inventory/inventory_slot.tscn")

@export var data: InventoryData
var focusIndex: int = 0

func _ready() -> void:
	# Connect PauseMenu signals to update or clear inventory UI
	PauseMenu.shown.connect(_on_pause_menu_shown)
	PauseMenu.hidden.connect(_on_pause_menu_hidden)
	
	# Connect inventory data change signal
	if data:
		data.inventory_changed.connect(_on_inventory_changed)
	
	_clearInventory()

# Clear all inventory slot nodes
func _clearInventory() -> void:
	for child in get_children():
		child.queue_free()

# Rebuild inventory UI, optionally focusing on a specific slot index
func _updateInventory(focus_pos: int = 0) -> void:
	_clearInventory()
	
	for slot in data.slots:
		var slotUI = INVENTORY_SLOT.instantiate()
		add_child(slotUI)
		slotUI.set_slot_data(slot)
		slotUI.focus_entered.connect(_on_item_focused)
	
	# Focus on the desired slot after a frame to ensure it's ready
	await get_tree().process_frame
	if get_child_count() > 0 and focus_pos < get_child_count():
		get_child(focus_pos).grab_focus()

# Signal handler: update focus index when a slot gains focus
func _on_item_focused() -> void:
	for i in range(get_child_count()):
		if get_child(i).has_focus():
			focusIndex = i
			break

# Called when inventory data signals a change — refresh UI and restore focus
func _on_inventory_changed() -> void:
	var currentFocus = focusIndex
	_updateInventory(currentFocus)

# Called when PauseMenu is shown — refresh inventory UI
func _on_pause_menu_shown() -> void:
	_updateInventory(focusIndex)

# Called when PauseMenu is hidden — clear inventory UI
func _on_pause_menu_hidden() -> void:
	_clearInventory()
