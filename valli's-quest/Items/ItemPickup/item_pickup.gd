@tool
class_name ItemPickup
extends CharacterBody2D

signal pickedUp

@export var itemData: ItemData

# Enum to track the internal state of the pickup
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

# Called when the node enters the scene tree
# Initializes references and sets the initial state based on whether running in editor
func _ready() -> void:
	_sprite = $Sprite2D  # Reference to sprite displaying the item
	_audio = $AudioStreamPlayer2D  # Audio player for pickup sound
	_detector = $Area2D  # Area used for detecting player proximity
	_isEditor = Engine.is_editor_hint()  # Check if running inside editor

	_bindDetector()  # Connect detection signals if needed
	_applyDataVisuals()  # Set sprite texture based on itemData

	# If in editor, stay idle; otherwise, wait for player proximity
	_state = PickupState.IDLE if _isEditor else PickupState.AWAITING_PLAYER

# Called each physics frame; handles floating movement unless pickup is done
func _physics_process(delta: float) -> void:
	if _state == PickupState.DONE:
		return  # No movement after pickup completed
	_processFloatingMovement(delta)  # Simulate floating and bouncing

# Sets up the detection area signal to detect player bodies entering
func _bindDetector() -> void:
	if _isEditor:
		_detector.monitoring = false  # Disable detection in editor mode
		return

	# Connect body_entered signal if not already connected
	if not _detector.body_entered.is_connected(_onDetectorEvent):
		_detector.body_entered.connect(_onDetectorEvent)

# Called when any body enters the detection area
# Checks if it's the player and attempts collection if so
func _onDetectorEvent(body: Node) -> void:
	if _state != PickupState.AWAITING_PLAYER:
		return  # Only react if waiting for player

	if not (body is Player):
		return  # Ignore if not the player

	_tryCollect()  # Attempt to add item to inventory and start collection sequence

# Tries to add the item to the player's inventory
# Starts the collection sequence if successful
func _tryCollect() -> void:
	if not itemData:
		return  # No item data, nothing to collect

	var added := PlayerManager.INVENTORY_DATA.addItem(itemData)  # Add item to inventory

	if added:
		_startCollectionSequence()  # Start pickup animation and logic

# Begins collection: disables further detection and triggers itemObtained
func _startCollectionSequence() -> void:
	_state = PickupState.COLLECTING

	# Disable area monitoring deferred to avoid signal conflicts
	_detector.set_deferred("monitoring", false)

	itemObtained()  # Process the item pickup visual/audio and freeing

# Handles visual/audio feedback and finalizes pickup
# Emits signal, plays audio, and frees the node after audio finishes
func itemObtained() -> void:
	visible = false  # Hide the pickup immediately
	pickedUp.emit()  # Notify listeners that pickup occurred

	_audio.play()  # Play pickup sound effect
	await _audio.finished  # Wait for sound to finish

	_state = PickupState.DONE
	queue_free()  # Remove pickup from scene

# Allows external code to set a new item and update visuals accordingly
func setItemData(value: ItemData) -> void:
	itemData = value
	_applyDataVisuals()  # Update sprite texture to match new item

# Updates the sprite texture based on the current itemData
func _applyDataVisuals() -> void:
	if not _sprite:
		return  # No sprite reference, nothing to update

	if not itemData:
		_sprite.texture = null  # Clear sprite if no item
		return

	_sprite.texture = itemData.texture  # Set sprite to item texture

# Simulates floating movement with simple bouncing when colliding
# Also applies velocity decay for smooth stopping
func _processFloatingMovement(delta: float) -> void:
	var hit = move_and_collide(velocity * delta)
	if hit:
		velocity = velocity.bounce(hit.get_normal())  # Bounce off collision surface

	velocity = velocity.move_toward(Vector2.ZERO, delta * 600)  # Gradually reduce velocity
