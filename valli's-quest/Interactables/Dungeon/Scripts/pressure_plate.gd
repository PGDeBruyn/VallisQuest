class_name PressurePlate
extends Node2D

signal activated
signal deactivated

var occupantCount: int = 0
var active: bool = false
var idleRegion: Rect2

@onready var trigger: Area2D = $Area2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var graphic: Sprite2D = $Sprite2D
@onready var sfxOn: AudioStream = preload("res://Interactables/Dungeon/lever-01.wav")
@onready var sfxOff: AudioStream = preload("res://Interactables/Dungeon/lever-02.wav")

func _ready() -> void:
	trigger.body_entered.connect(_increment)
	trigger.body_exited.connect(_decrement)
	idleRegion = graphic.region_rect


func _increment(_body: Node2D) -> void:
	occupantCount += 1
	_update_state()

func _decrement(_body: Node2D) -> void:
	occupantCount = max(occupantCount - 1, 0) # prevent negative counts
	_update_state()


func _update_state() -> void:
	var shouldBeActive: bool = occupantCount > 0

	if shouldBeActive != active:
		active = shouldBeActive
		_apply_visual()
		_play_sfx()
		_emit_status()


func _apply_visual() -> void:
	var r: Rect2 = idleRegion # Rect2 is a value type; this makes a copy
	if active:
		r.position.x = idleRegion.position.x - 32
	else:
		r.position.x = idleRegion.position.x
	graphic.region_rect = r


func _play_sfx() -> void:
	if not sfx.is_inside_tree():
		return
	
	if active:
		sfx.stream = sfxOn
	else:
		sfx.stream = sfxOff
	sfx.play()


func _emit_status() -> void:
	if active:
		activated.emit()
	else:
		deactivated.emit()
