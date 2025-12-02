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
	_initNpc()
	if Engine.is_editor_hint():
		return
	_connectInteractables()
	emit_signal("behavior_toggled", behaviorActive)

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _initNpc() -> void:
	if npcResource and spriteNode:
		spriteNode.texture = npcResource.sprite

func _connectInteractables() -> void:
	interactables.clear()
	for child in get_children():
		if child is DialogueInteraction:
			if child.has_signal("player_interacted"):
				child.player_interacted.connect(_onPlayerInteracted)
			else:
				print("Warning: DialogueInteraction node missing 'player_interacted' signal")
			if child.has_signal("finished"):
				child.finished.connect(_onInteractionComplete)
			else:
				print("Warning: DialogueInteraction node missing 'finished' signal")
			interactables.append(child)
		else:
			print("Child %s is not DialogueInteraction" % child.name)


func _onPlayerInteracted() -> void:
	_lookAtPosition(PlayerManager.player.global_position)
	state = "idle"
	velocity = Vector2.ZERO
	_updateAnimation()
	behaviorActive = false
	emit_signal("behavior_toggled", behaviorActive)

func _onInteractionComplete() -> void:
	state = "idle"
	_updateAnimation()
	behaviorActive = true
	emit_signal("behavior_toggled", behaviorActive)

func _updateAnimation() -> void:
	animPlayer.play("%s_%s" % [state, facingName])

func _lookAtPosition(targetPos: Vector2) -> void:
	facingDirection = (targetPos - global_position).normalized()
	_setFacingName()
	# Flip sprite horizontally if looking left on side animation
	if facingName == "side":
		spriteNode.flip_h = facingDirection.x < 0
	else:
		spriteNode.flip_h = false

func _setFacingName() -> void:
	var threshold = 0.45
	if facingDirection.y < -threshold:
		facingName = "up"
	elif facingDirection.y > threshold:
		facingName = "down"
	elif abs(facingDirection.x) > threshold:
		facingName = "side"
	else:
		facingName = "down"  # fallback

func setNpcResource(res: NPCResource) -> void:
	npcResource = res
	_initNpc()
