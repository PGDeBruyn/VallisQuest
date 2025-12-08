@tool
@icon("res://GUI/dialogue_system/icons/chat_bubbles.svg")
class_name DialogueInteraction
extends Area2D

signal playerInteracted
signal finished

@export var enabled: bool = true

var dialogueItems: Array[DialogueItem] = []

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Setup signals and cache dialogue items unless in editor
	if Engine.is_editor_hint():
		return
	area_entered.connect(_onAreaEnter)
	area_exited.connect(_onAreaExit)

	dialogueItems.clear()
	for child in get_children():
		if child is DialogueItem:
			dialogueItems.append(child)

func _get_configuration_warnings() -> PackedStringArray:
	# Warn if no DialogueItems present
	if dialogueItems.size() == 0:
		return ["Requires at least one DialogueItem node."]
	return []

func playerInteract() -> void:
	# Emit interaction signal and start dialogue display
	playerInteracted.emit()

	await get_tree().process_frame
	await get_tree().process_frame

	# Preload NPC portrait and audio settings before showing dialogue
	if dialogueItems.size() > 0 and dialogueItems[0].npcInfo:
		DialogueSystem.portraitSprite.texture = dialogueItems[0].npcInfo.portrait
		DialogueSystem.nameLabel.text = dialogueItems[0].npcInfo.npcName
		DialogueSystem.portraitSprite.audio_pitch_base = dialogueItems[0].npcInfo.dialogueAudioPitch

	DialogueSystem.showDialogue(dialogueItems)
	DialogueSystem.finished.connect(_onDialogueFinished)

func _onAreaEnter(_area: Area2D) -> void:
	# Play show animation and connect interaction input on area enter
	if not enabled or dialogueItems.size() == 0:
		return
	animationPlayer.play("show")
	PlayerManager.interactPressed.connect(playerInteract)

func _onAreaExit(_area: Area2D) -> void:
	# Play hide animation and disconnect interaction input on area exit
	animationPlayer.play("hide")
	PlayerManager.interactPressed.disconnect(playerInteract)

func _onDialogueFinished() -> void:
	# Disconnect finished signal and emit finished
	DialogueSystem.finished.disconnect(_onDialogueFinished)
	finished.emit()
