@tool
class_name ItemDropper
extends Node2D

const PICKUP_SCENE = preload("res://Items/ItemPickup/item_pickup.tscn")

@export var itemData: ItemData

signal itemDropped
signal itemCollected

enum DropState { WAITING, DROPPED, COLLECTED }

var _state: DropState = DropState.WAITING
var _pickupInstance: ItemPickup

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var persistentData: PersistentDataHandler = $PersistentDataHandler

# Initializes node, setting sprite visibility and connecting data signals.
func _ready() -> void:
	if Engine.is_editor_hint():
		_updateSpriteTexture()
		return

	sprite.visible = false
	persistentData.dataLoaded.connect(_onDataLoaded)
	_onDataLoaded()

# Updates dropper state based on persistent data load.
func _onDataLoaded() -> void:
	if persistentData.value:
		_state = DropState.COLLECTED
		_hideDropper()
	else:
		_state = DropState.WAITING
		_hideDropper()  # Hidden until dropItem is called

# Sets item data and updates sprite texture.
func setItemData(value: ItemData) -> void:
	itemData = value
	_updateSpriteTexture()

# Updates sprite texture in editor for visual feedback.
func _updateSpriteTexture() -> void:
	if Engine.is_editor_hint() and sprite and itemData:
		sprite.texture = itemData.texture

# Starts the item drop if waiting.
func dropItem() -> void:
	if _state != DropState.WAITING:
		return

	_state = DropState.DROPPED

	_hideDropper()
	_spawnPickup()

	audio.play()
	itemDropped.emit()

# Instantiates the pickup item and connects collection signal.
func _spawnPickup() -> void:
	_pickupInstance = PICKUP_SCENE.instantiate() as ItemPickup
	_pickupInstance.itemData = itemData

	add_child(_pickupInstance)
	_pickupInstance.pickedUp.connect(_onItemCollected)

# Handles pickup collection, updates state and emits signal.
func _onItemCollected() -> void:
	_state = DropState.COLLECTED
	persistentData.setValue()

	itemCollected.emit()
	_hideDropper()

# Hides the dropper sprite.
func _hideDropper() -> void:
	sprite.visible = false
