@tool
class_name TreasureChest
extends Node2D

@export var itemData: ItemData
@export var quantity: int = 1

var is_open: bool = false

@onready var sprite: Sprite2D = $ItemSprite
@onready var label: Label = $ItemSprite/Label
@onready var interact_area: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var persistent_data: PersistentDataHandler = $IsOpen

func _ready() -> void:
	_refresh_visuals()
	if Engine.is_editor_hint():
		return
	interact_area.area_entered.connect(_on_area_entered)
	interact_area.area_exited.connect(_on_area_exited)
	persistent_data.dataLoaded.connect(_on_data_loaded)
	_on_data_loaded()

func _on_data_loaded() -> void:
	is_open = persistent_data.value
	_update_animation()

func _update_animation() -> void:
	if is_open:
		animation_player.play("opened")
	else:
		animation_player.play("closed")

func player_interact() -> void:
	if is_open:
		return
	is_open = true
	persistent_data.setValue()
	animation_player.play("open_chest")
	if itemData and quantity > 0:
		var inventory = PlayerManager.get_inventory()
		if inventory:
			inventory.addItem(itemData, quantity)
			#print(itemData.name, quantity)
		else:
			push_error("Inventory not available when opening chest: %s" % name)
	else:
		push_error("Chest has no items: %s" % name)

func _on_area_entered(_area: Area2D) -> void:
	if not PlayerManager.interactPressed.is_connected(player_interact):
		PlayerManager.interactPressed.connect(player_interact)

func _on_area_exited(_area: Area2D) -> void:
	if PlayerManager.interactPressed.is_connected(player_interact):
		PlayerManager.interactPressed.disconnect(player_interact)

func set_item_data(new_item: ItemData) -> void:
	itemData = new_item
	_refresh_visuals()

func set_quantity(new_quantity: int) -> void:
	quantity = new_quantity
	_refresh_visuals()

func _refresh_visuals() -> void:
	if sprite and itemData:
		sprite.texture = itemData.texture
	if label:
		label.text = _format_quantity()

func _format_quantity() -> String:
	return "x%d" % quantity if quantity > 1 else ""
