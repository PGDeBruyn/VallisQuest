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
	_interactionCallable = Callable(self, "openDoor")
	interactArea.area_entered.connect(_onEnter)
	interactArea.area_exited.connect(_onExit)
	stateData.dataLoaded.connect(_applyPersistentState)

# ------------------------------------------------------------------------------

func openDoor() -> void:
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
	_update_state(DoorState.CLOSED)

# ------------------------------------------------------------------------------

func _update_state(target: DoorState) -> void:
	if target == state:
		return

	state = target
	_sync_animation()

func _sync_animation() -> void:
	match state:
		DoorState.OPEN:
			_play_anim("open_door")
		DoorState.CLOSED:
			_play_anim("close_door")

# Small helpers for visuals/audio control
func _play_anim(name: String) -> void:
	if animator.has_animation(name):
		animator.play(name)

func _play_sfx(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

# ------------------------------------------------------------------------------

# Restore saved state without playing unlock/lock sounds
func _applyPersistentState() -> void:
	var was_open: bool = stateData.value
	state = DoorState.OPEN if was_open else DoorState.CLOSED

	var anim_name: String = "opened" if was_open else "closed"
	_play_anim(anim_name)

# ------------------------------------------------------------------------------

func _onEnter(_area: Area2D) -> void:
	# connect using the stored callable so disconnect() can find the exact same target
	if not PlayerManager.interactPressed.is_connected(_interactionCallable):
		PlayerManager.interactPressed.connect(_interactionCallable)

func _onExit(_area: Area2D) -> void:
	if PlayerManager.interactPressed.is_connected(_interactionCallable):
		PlayerManager.interactPressed.disconnect(_interactionCallable)
