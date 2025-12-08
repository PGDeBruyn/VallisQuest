class_name ItemMagnet
extends Area2D

@export var magnetStrength: float = 1.0
@export var playMagnetAudio: bool = false

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var attractedItems := {}
var followingItems := []

# Connects area_entered signal on ready.
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# Starts attracting item when it enters the magnet area.
func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is ItemPickup and not attractedItems.has(parent) and not followingItems.has(parent):
		_start_attracting(parent)

# Initiates tween to move item towards the magnet.
func _start_attracting(item: ItemPickup) -> void:
	item.set_physics_process(false)

	var distance = item.global_position.distance_to(global_position)
	var duration = max(0.1, distance / (magnetStrength * 200))

	var tween = get_tree().create_tween()
	tween.tween_property(item, "global_position", global_position, duration)

	tween.finished.connect(func():
		_on_item_attracted(item)
	)

	attractedItems[item] = tween

	if playMagnetAudio and attractedItems.size() == 1:
		audio.play()

# Finalizes attraction and adds item to following list.
func _on_item_attracted(item: ItemPickup) -> void:
	if attractedItems.has(item):
		attractedItems.erase(item)

	if is_instance_valid(item):
		item.global_position = global_position
		if not followingItems.has(item):
			followingItems.append(item)

# Updates positions of all following items each frame.
func _process(_delta: float) -> void:
	for item in followingItems:
		if is_instance_valid(item):
			item.global_position = global_position
		else:
			followingItems.erase(item)

	for item in attractedItems.keys():
		if not is_instance_valid(item):
			attractedItems.erase(item)
