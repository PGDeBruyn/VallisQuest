@tool
@icon("res://npc/icons/npc.svg")
class_name NPC
extends CharacterBody2D

signal behavior_toggled(enabled: bool)

@export var npcResource: NPCResource : set = setNpcResource

@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var spriteNode: Sprite2D = $Sprite2D

var state := "idle"
var facingDirection := Vector2.DOWN
var facingName := "down"
var behaviorActive := true
var interactables := []

func _ready() -> void:
	# Initialize NPC appearance and connect interactable signals
	_initNpc()
	# Skip runtime setup in editor preview
	if Engine.is_editor_hint():
		return
	_connectInteractables()
	# Notify listeners that behavior is active at start
	emit_signal("behavior_toggled", behaviorActive)

func _physics_process(_delta: float) -> void:
	# Simple movement logic: move according to current velocity and slide on collision
	move_and_slide()

func _initNpc() -> void:
	# Set the sprite texture based on assigned NPC resource (appearance)
	if npcResource and spriteNode:
		spriteNode.texture = npcResource.sprite

func _connectInteractables() -> void:
	# Find all DialogueInteraction children, connect signals, and store references
	interactables.clear()
	for child in get_children():
		if child is DialogueInteraction:
			# Connect 'player_interacted' signal if it exists, else warn
			if child.has_signal("player_interacted"):
				child.player_interacted.connect(_onPlayerInteracted)
			else:
				print("Warning: DialogueInteraction node missing 'player_interacted' signal")
			# Connect 'finished' signal if it exists, else warn
			if child.has_signal("finished"):
				child.finished.connect(_onInteractionComplete)
			else:
				print("Warning: DialogueInteraction node missing 'finished' signal")
			interactables.append(child)
		else:
			print("Child %s is not DialogueInteraction" % child.name)

func _onPlayerInteracted() -> void:
	# When player interacts, NPC faces player, stops movement, updates animation, and disables behavior temporarily
	_lookAtPosition(PlayerManager.player.global_position)
	state = "idle"
	velocity = Vector2.ZERO
	_updateAnimation()
	behaviorActive = false
	emit_signal("behavior_toggled", behaviorActive)

func _onInteractionComplete() -> void:
	# When interaction ends, NPC returns to idle behavior and notifies listeners
	state = "idle"
	_updateAnimation()
	behaviorActive = true
	emit_signal("behavior_toggled", behaviorActive)

func _updateAnimation() -> void:
	# Play animation based on current state and facing direction
	animPlayer.play("%s_%s" % [state, facingName])

func _lookAtPosition(targetPos: Vector2) -> void:
	# Calculate normalized direction vector to target position and update facing info
	facingDirection = (targetPos - global_position).normalized()
	_setFacingName()
	# Flip sprite horizontally if facing left in side animation; otherwise, don't flip
	if facingName == "side":
		spriteNode.flip_h = facingDirection.x < 0
	else:
		spriteNode.flip_h = false

func _setFacingName() -> void:
	# Determine facingName based on facingDirection with threshold to avoid jitter
	var threshold = 0.45
	if facingDirection.y < -threshold:
		facingName = "up"
	elif facingDirection.y > threshold:
		facingName = "down"
	elif abs(facingDirection.x) > threshold:
		facingName = "side"
	else:
		facingName = "down"  # fallback to down

func setNpcResource(res: NPCResource) -> void:
	# Setter for npcResource that also initializes sprite texture
	npcResource = res
	_initNpc()
