class_name BarredDoor
extends Node2D

enum DoorState { CLOSED, OPEN }

@onready var animator: AnimationPlayer = $AnimationPlayer

var state: DoorState = DoorState.CLOSED

func _ready() -> void:
	# Synchronize animation with current door state on ready
	_sync_animation()

func openDoor() -> void:
	# Open the door by changing its state to OPEN
	_change_state(DoorState.OPEN)

func closeDoor() -> void:
	# Close the door by changing its state to CLOSED
	_change_state(DoorState.CLOSED)

func _change_state(target: DoorState) -> void:
	# Change door state only if different from current
	if target == state:
		return
	
	state = target
	# Update animation to match new state
	_sync_animation()

func _sync_animation() -> void:
	# Play animation based on door state
	match state:
		DoorState.OPEN:
			_play_anim("open_door")
		DoorState.CLOSED:
			_play_anim("close_door")

func _play_anim(anim: String) -> void:
	# Play animation if it exists
	if animator.has_animation(anim):
		animator.play(anim)
