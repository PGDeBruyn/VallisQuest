class_name InventoryUI
extends Control

const INVENTORY_SLOT = preload("res://GUI/PauseMenu/Inventory/inventory_slot.tscn")

@export var data: InventoryData
var focusIndex: int = 0

func _ready() -> void:
	# Connect to PauseMenu signals to manage inventory UI visibility and updates
	PauseMenu.shown.connect(_on_pause_menu_shown)
	PauseMenu.hidden.connect(_on_pause_menu_hidden)
	
	# Connect to inventory data changes to refresh UI when inventory updates
	if data:
		data.inventory_changed.connect(_on_inventory_changed)
	
	_clearInventory()

# Remove all child slot UI nodes to clear the inventory display
func _clearInventory() -> void:
	for child in get_children():
		child.queue_free()

# Build or rebuild the inventory UI with slots representing each item
# Optionally focuses a specified slot after the UI updates
func _updateInventory(focus_pos: int = 0) -> void:
	_clearInventory()
	
	for slot in data.slots:
		var slotUI = INVENTORY_SLOT.instantiate()
		add_child(slotUI)

		# Assign slot data and link to PauseMenu for item description updates
		slotUI.set_slot_data(slot)
		slotUI.pause_menu = PauseMenu

		# Connect focus entered signal to track current focused slot
		slotUI.focus_entered.connect(_on_item_focused)
	
	await get_tree().process_frame

	# Focus the desired slot to maintain navigation position
	if get_child_count() > 0 and focus_pos < get_child_count():
		get_child(focus_pos).grab_focus()

	# Ensure focus is set after UI fully updates (two frames)
	await get_tree().process_frame
	if get_child_count() > 0 and focus_pos < get_child_count():
		get_child(focus_pos).grab_focus()

# Update the current focus index when a slot gains focus
func _on_item_focused() -> void:
	for i in range(get_child_count()):
		if get_child(i).has_focus():
			focusIndex = i
			break

# Refresh the inventory UI when the inventory data changes, preserving focus
func _on_inventory_changed() -> void:
	var currentFocus = focusIndex
	_updateInventory(currentFocus)

# Show inventory UI when PauseMenu is displayed
func _on_pause_menu_shown() -> void:
	_updateInventory(focusIndex)

# Clear inventory UI when PauseMenu is hidden
func _on_pause_menu_hidden() -> void:
	_clearInventory()
