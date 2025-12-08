@tool
class_name TreasureChest
extends Node2D

@export var itemData: ItemData  # The item contained in the chest
@export var quantity: int = 1   # Quantity of the item in the chest

var is_open: bool = false       # Tracks if the chest has been opened

@onready var sprite: Sprite2D = $ItemSprite           # Sprite to show the item's texture
@onready var label: Label = $ItemSprite/Label         # Label to show item quantity
@onready var interact_area: Area2D = $Area2D           # Area detecting player interaction
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Controls chest animations
@onready var persistent_data: PersistentDataHandler = $IsOpen      # Persistent state handler for whether chest is open

func _ready() -> void:
	# Update visuals and connect signals unless in editor
	_refresh_visuals()
	if Engine.is_editor_hint():
		return
	interact_area.area_entered.connect(_on_area_entered)
	interact_area.area_exited.connect(_on_area_exited)
	persistent_data.dataLoaded.connect(_on_data_loaded)
	_on_data_loaded()

func _on_data_loaded() -> void:
	# Load the open state and update animation accordingly
	is_open = persistent_data.value
	_update_animation()

func _update_animation() -> void:
	# Play the appropriate animation based on open state
	if is_open:
		animation_player.play("opened")
	else:
		animation_player.play("closed")

func player_interact() -> void:
	# Handle player interaction with chest
	if is_open:
		return
	is_open = true
	persistent_data.setValue()
	animation_player.play("open_chest")
	if itemData and quantity > 0:
		var inventory = PlayerManager.get_inventory()
		if inventory:
			inventory.addItem(itemData, quantity)
		else:
			push_error("Inventory not available when opening chest: %s" % name)
	else:
		push_error("Chest has no items: %s" % name)

func _on_area_entered(_area: Area2D) -> void:
	# Connect interaction signal when player enters area
	if not PlayerManager.interactPressed.is_connected(player_interact):
		PlayerManager.interactPressed.connect(player_interact)

func _on_area_exited(_area: Area2D) -> void:
	# Disconnect interaction signal when player leaves area
	if PlayerManager.interactPressed.is_connected(player_interact):
		PlayerManager.interactPressed.disconnect(player_interact)

func set_item_data(new_item: ItemData) -> void:
	# Update the item data and refresh visuals
	itemData = new_item
	_refresh_visuals()

func set_quantity(new_quantity: int) -> void:
	# Update the quantity and refresh visuals
	quantity = new_quantity
	_refresh_visuals()

func _refresh_visuals() -> void:
	# Update the sprite texture and quantity label
	if sprite and itemData:
		sprite.texture = itemData.texture
	if label:
		label.text = _format_quantity()

func _format_quantity() -> String:
	# Format quantity text; empty if quantity is 1
	return "x%d" % quantity if quantity > 1 else ""
