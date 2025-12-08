class_name PressurePlate
extends Node2D

signal activated  # Emitted when the plate becomes active
signal deactivated  # Emitted when the plate becomes inactive

var occupantCount: int = 0  # Number of bodies currently on the plate
var active: bool = false  # Whether the plate is currently active
var idleRegion: Rect2  # Default sprite region for visual state

@onready var trigger: Area2D = $Area2D  # Area detecting bodies on plate
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D  # Sound player
@onready var graphic: Sprite2D = $Sprite2D  # Visual representation of plate
@onready var sfxOn: AudioStream = preload("res://Interactables/Dungeon/lever-01.wav")  # Activation sound
@onready var sfxOff: AudioStream = preload("res://Interactables/Dungeon/lever-02.wav")  # Deactivation sound

func _ready() -> void:
	# Connect signals for bodies entering/exiting the plate's area
	trigger.body_entered.connect(_increment)
	trigger.body_exited.connect(_decrement)
	idleRegion = graphic.region_rect  # Store the initial sprite region

func _increment(_body: Node2D) -> void:
	# Increase occupant count when a body enters
	occupantCount += 1
	_update_state()

func _decrement(_body: Node2D) -> void:
	# Decrease occupant count when a body leaves, clamped to zero
	occupantCount = max(occupantCount - 1, 0)
	_update_state()

func _update_state() -> void:
	# Determine if the plate should be active and update if state changed
	var shouldBeActive: bool = occupantCount > 0

	if shouldBeActive != active:
		active = shouldBeActive
		_apply_visual()
		_play_sfx()
		_emit_status()

func _apply_visual() -> void:
	# Adjust sprite region to reflect active/inactive state
	var r: Rect2 = idleRegion  # Copy original region
	if active:
		r.position.x = idleRegion.position.x - 32
	else:
		r.position.x = idleRegion.position.x
	graphic.region_rect = r

func _play_sfx() -> void:
	# Play activation or deactivation sound if node is in scene tree
	if not sfx.is_inside_tree():
		return
	
	if active:
		sfx.stream = sfxOn
	else:
		sfx.stream = sfxOff
	sfx.play()

func _emit_status() -> void:
	# Emit corresponding signal based on active state
	if active:
		activated.emit()
	else:
		deactivated.emit()
