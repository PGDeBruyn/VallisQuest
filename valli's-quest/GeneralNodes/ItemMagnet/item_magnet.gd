class_name ItemMagnet
extends Area2D

@export var magnetStrength: float = 1.0
@export var playMagnetAudio: bool = false

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var attractedItems := {}

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is ItemPickup and not attractedItems.has(parent):
		_start_attracting(parent)


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


func _on_item_attracted(item: ItemPickup) -> void:
	if attractedItems.has(item):
		attractedItems.erase(item)

	if is_instance_valid(item):
		item.global_position = global_position


func _process(_delta: float) -> void:
	for item in attractedItems.keys():
		if not is_instance_valid(item):
			attractedItems.erase(item)
