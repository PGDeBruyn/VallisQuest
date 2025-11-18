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

func _ready() -> void:
	if Engine.is_editor_hint():
		_updateSpriteTexture()
		return

	sprite.visible = false
	persistentData.dataLoaded.connect(_onDataLoaded)
	_onDataLoaded()

func _onDataLoaded() -> void:
	if persistentData.value:
		_state = DropState.COLLECTED
		_hideDropper()
	else:
		_state = DropState.WAITING
		_hideDropper()  # Hidden until dropItem is called

func setItemData(value: ItemData) -> void:
	itemData = value
	_updateSpriteTexture()

func _updateSpriteTexture() -> void:
	if Engine.is_editor_hint() and sprite and itemData:
		sprite.texture = itemData.texture

func dropItem() -> void:
	if _state != DropState.WAITING:
		return

	_state = DropState.DROPPED

	_hideDropper()
	_spawnPickup()

	audio.play()
	itemDropped.emit()

func _spawnPickup() -> void:
	_pickupInstance = PICKUP_SCENE.instantiate() as ItemPickup
	_pickupInstance.itemData = itemData

	add_child(_pickupInstance)
	_pickupInstance.pickedUp.connect(_onItemCollected)

func _onItemCollected() -> void:
	_state = DropState.COLLECTED
	persistentData.setValue()

	itemCollected.emit()
	_hideDropper()

func _hideDropper() -> void:
	sprite.visible = false
