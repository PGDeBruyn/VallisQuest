@tool
class_name ItemPickup
extends CharacterBody2D

signal pickedUp

@export var itemData: ItemData

# Internal State Types
enum PickupState {
	IDLE,
	AWAITING_PLAYER,
	COLLECTING,
	DONE
}

var _state: PickupState = PickupState.IDLE
var _detector: Area2D
var _sprite: Sprite2D
var _audio: AudioStreamPlayer2D
var _isEditor: bool = false


func _ready() -> void:
	# Establish references once
	_sprite = $Sprite2D
	_audio = $AudioStreamPlayer2D
	_detector = $Area2D
	_isEditor = Engine.is_editor_hint()

	_bindDetector()
	_applyDataVisuals()

	# Move immediately into the appropriate starting state
	_state = PickupState.IDLE if _isEditor else PickupState.AWAITING_PLAYER


func _physics_process(delta: float) -> void:
	if _state == PickupState.DONE:
		return

	_processFloatingMovement(delta)


# -------------------------------------------------------------------
# --- CENTRALIZED DETECTOR ROUTING ----------------------------------
# -------------------------------------------------------------------

func _bindDetector() -> void:
	# editor mode: no detection needed
	if _isEditor:
		_detector.monitoring = false
		return

	# connect once, route through handler
	if not _detector.body_entered.is_connected(_onDetectorEvent):
		_detector.body_entered.connect(_onDetectorEvent)


func _onDetectorEvent(body: Node) -> void:
	if _state != PickupState.AWAITING_PLAYER:
		return

	if not (body is Player):
		return

	_tryCollect()


# -------------------------------------------------------------------
# --- SELF-CONTAINED COLLECTION CONTROLLER --------------------------
# -------------------------------------------------------------------

func _tryCollect() -> void:
	if not itemData:
		return

	var added := PlayerManager.INVENTORY_DATA.addItem(itemData)

	if added:
		_startCollectionSequence()


func _startCollectionSequence() -> void:
	_state = PickupState.COLLECTING

	# Must be deferred — cannot modify monitoring during body_entered
	_detector.set_deferred("monitoring", false)

	itemObtained()



# -------------------------------------------------------------------
# --- REQUIRED NAME: itemObtained (rewritten internally) ------------
# -------------------------------------------------------------------

func itemObtained() -> void:
	# Hide first for immediate visual feedback
	visible = false
	pickedUp.emit()

	_audio.play()
	await _audio.finished

	_state = PickupState.DONE
	queue_free()


# -------------------------------------------------------------------
# --- VISUAL / EDITOR LOGIC -----------------------------------------
# -------------------------------------------------------------------

func setItemData(value: ItemData) -> void:
	itemData = value
	_applyDataVisuals()


func _applyDataVisuals() -> void:
	if not _sprite:
		return
	if not itemData:
		_sprite.texture = null
		return
	_sprite.texture = itemData.texture


# -------------------------------------------------------------------
# --- MOVEMENT / FLOATING -------------------------------------------
# -------------------------------------------------------------------

func _processFloatingMovement(delta: float) -> void:
	var hit = move_and_collide(velocity * delta)
	if hit:
		velocity = velocity.bounce(hit.get_normal())

	# decay (fast stop)
	velocity = velocity.move_toward(Vector2.ZERO, delta * 600)
