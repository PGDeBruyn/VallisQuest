class_name LockedDoor
extends Node2D

enum DoorState { CLOSED, OPEN }

@export var keyItem: ItemData
@export var lockedAudio: AudioStream
@export var openAudio: AudioStream

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var stateData: PersistentDataHandler = $PersistentDataHandler
@onready var interactArea: Area2D = $InteractArea2D

var state: DoorState = DoorState.CLOSED
var _interactionCallable: Callable

func _ready() -> void:
	# Prepare the callable for interaction and connect signals
	_interactionCallable = Callable(self, "openDoor")
	interactArea.area_entered.connect(_onEnter)
	interactArea.area_exited.connect(_onExit)
	stateData.dataLoaded.connect(_applyPersistentState)

func openDoor() -> void:
	# Attempt to open the door using the key item if player has it
	if keyItem == null:
		return

	var succeeded: bool = PlayerManager.INVENTORY_DATA.useItem(keyItem)

	if succeeded:
		_update_state(DoorState.OPEN)
		stateData.setValue()
		_play_sfx(openAudio)
	else:
		_play_sfx(lockedAudio)

func closeDoor() -> void:
	# Close the door and update state
	_update_state(DoorState.CLOSED)

func _update_state(target: DoorState) -> void:
	# Change state only if different and sync animation
	if target == state:
		return

	state = target
	_sync_animation()

func _sync_animation() -> void:
	# Play animation based on door state
	match state:
		DoorState.OPEN:
			_play_anim("open_door")
		DoorState.CLOSED:
			_play_anim("close_door")

func _play_anim(name: String) -> void:
	# Play animation if it exists
	if animator.has_animation(name):
		animator.play(name)

func _play_sfx(stream: AudioStream) -> void:
	# Play sound effect
	sfx.stream = stream
	sfx.play()

func _applyPersistentState() -> void:
	# Restore door state from saved data without playing sounds
	var was_open: bool = stateData.value
	state = DoorState.OPEN if was_open else DoorState.CLOSED

	var anim_name: String = "opened" if was_open else "closed"
	_play_anim(anim_name)

func _onEnter(_area: Area2D) -> void:
	# Connect interaction input when player enters area
	if not PlayerManager.interactPressed.is_connected(_interactionCallable):
		PlayerManager.interactPressed.connect(_interactionCallable)

func _onExit(_area: Area2D) -> void:
	# Disconnect interaction input when player exits area
	if PlayerManager.interactPressed.is_connected(_interactionCallable):
		PlayerManager.interactPressed.disconnect(_interactionCallable)
