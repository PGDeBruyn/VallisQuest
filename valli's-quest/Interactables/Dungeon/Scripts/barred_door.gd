class_name BarredDoor
extends Node2D

enum DoorState { CLOSED, OPEN }

@onready var animator: AnimationPlayer = $AnimationPlayer

var state: DoorState = DoorState.CLOSED

func _ready() -> void:
	_sync_animation()

# -- Public API ---------------------------------------------------------------

func openDoor() -> void:
	_change_state(DoorState.OPEN)

func closeDoor() -> void:
	_change_state(DoorState.CLOSED)

func _change_state(target: DoorState) -> void:
	if target == state:
		return  # no-op if already in this state
	
	state = target
	_sync_animation()

func _sync_animation() -> void:
	match state:
		DoorState.OPEN:
			_play_anim("open_door")
		DoorState.CLOSED:
			_play_anim("close_door")

func _play_anim(anim: String) -> void:
	if animator.has_animation(anim):
		animator.play(anim)


func _on_pressure_plate_activated() -> void:
	pass # Replace with function body.


func _on_pressure_plate_deactivated() -> void:
	pass # Replace with function body.
