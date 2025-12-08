@tool
@icon("res://GUI/dialogue_system/icons/chat_bubbles.svg")
class_name DialogueSystemNode
extends CanvasLayer

signal finished
signal letterAdded(letter: String)

# New signals for dialogue start/end
signal dialogue_started
signal dialogue_ended

var isActive: bool = false
var isDialogueRunning: bool = false  # NEW flag to track dialogue running state
var textInProgress: bool = false
var textSpeed: float = 0.02
var textLength: int = 0
var plainText: String = ""
var dialogueItems: Array[DialogueItem] = []
var dialogueItemIndex: int = 0
var waitingForChoice: bool = false


@onready var dialogueUI: Control = $DialogueUI
@onready var content: RichTextLabel = $DialogueUI/PanelContainer/RichTextLabel
@onready var nameLabel: Label = $DialogueUI/NameLabel
@onready var portraitSprite: DialoguePortrait = $DialogueUI/PortraitSprite
@onready var dialogueProgress: PanelContainer = $DialogueUI/DialogueProgress
@onready var dialogueProgressLabel: Label = $DialogueUI/DialogueProgress/Label
@onready var timer: Timer = $DialogueUI/Timer
@onready var audioStreamPlayer: AudioStreamPlayer = $DialogueUI/AudioStreamPlayer
@onready var choiceOptions: VBoxContainer = $DialogueUI/VBoxContainer

# Initializes the dialogue system and hides dialogue UI on start.
func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
	timer.timeout.connect(_onTimerTimeout)
	hideDialogue()

# Handles input for advancing dialogue or skipping text.
func _unhandled_input(event: InputEvent) -> void:
	if not isActive:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("attack") or event.is_action_pressed("ui_accept"):
		if textInProgress:
			content.visible_characters = textLength
			timer.stop()
			textInProgress = false
			_showDialogueButtonIndicator(true)
			return
		# Skip input if waiting for player choice buttons
		if waitingForChoice:
			return

		dialogueItemIndex += 1
		if dialogueItemIndex < dialogueItems.size():
			startDialogue()
		else:
			print("hiding dialogue")
			hideDialogue()

# Starts showing a sequence of dialogue items and pauses the game.
func showDialogue(items: Array[DialogueItem]) -> void:
	isActive = true
	isDialogueRunning = true
	dialogue_started.emit()
	dialogueUI.visible = true
	dialogueUI.process_mode = Node.PROCESS_MODE_ALWAYS
	dialogueItems = items
	dialogueItemIndex = 0
	get_tree().paused = true
	await get_tree().process_frame
	startDialogue()

# Hides dialogue UI, unpauses the game if appropriate, and emits finished signal.
func hideDialogue() -> void:
	isActive = false
	isDialogueRunning = false
	dialogue_ended.emit()
	choiceOptions.visible = false
	dialogueUI.visible = false
	dialogueUI.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Only unpause if shop menu is not active
	if not ShopMenu.isActive:
		get_tree().paused = false
	
	finished.emit()

# Begins the current dialogue item, handles text or choice types.
func startDialogue() -> void:
	waitingForChoice = false
	_showDialogueButtonIndicator(false)

	if dialogueItems.size() == 0:
		return

	var d: DialogueItem = dialogueItems[dialogueItemIndex]
	if d is DialogueText:
		_setDialogueText(d as DialogueText)
	elif d is DialogueChoice:
		_setDialogueChoice(d as DialogueChoice)

# Sets up dialogue text display and starts the text reveal timer.
func _setDialogueText(d: DialogueText) -> void:
	content.text = d.text
	if d.npcInfo:
		nameLabel.text = d.npcInfo.npcName
		portraitSprite.texture = d.npcInfo.portrait
		portraitSprite.audio_pitch_base = d.npcInfo.dialogueAudioPitch
	else:
		nameLabel.text = "???"
		portraitSprite.texture = null
		portraitSprite.audio_pitch_base = 1.0
	content.visible_characters = 0
	textLength = content.get_total_character_count()
	plainText = content.get_parsed_text()
	textInProgress = true
	_startTimer()

# Shows or hides the "NEXT"/"END" indicator during dialogue.
func _showDialogueButtonIndicator(isVisible: bool) -> void:
	dialogueProgress.visible = isVisible
	
	if dialogueItemIndex + 1 < dialogueItems.size():
		dialogueProgressLabel.text = "NEXT"
	else:
		dialogueProgressLabel.text = "END"

# Starts the timer for text reveal speed, adjusting for punctuation pauses.
func _startTimer() -> void:
	timer.wait_time = textSpeed
	var c = plainText[content.visible_characters - 1]
	if '.!?:;'.find(c) >= 0:
		timer.wait_time *= 4
	elif ', '.find(c) >= 0:
		timer.wait_time *= 2
	timer.start()

# Called when timer times out; reveals next character or shows indicator when done.
func _onTimerTimeout() -> void:
	content.visible_characters += 1
	if content.visible_characters <= textLength:
		letterAdded.emit(plainText[content.visible_characters - 1])
		_startTimer()
	else:
		_showDialogueButtonIndicator(true)
		textInProgress = false

# Sets up UI for dialogue choices and waits for player selection.
func _setDialogueChoice(d: DialogueChoice) -> void:
	choiceOptions.visible = true
	waitingForChoice = true

	# Clear existing choice buttons
	for child in choiceOptions.get_children():
		child.queue_free()

	# Create buttons for each branch choice
	for i in range(d.get_branches().size()):
		var branch = d.get_branches()[i]
		var newChoice = Button.new()
		newChoice.text = branch.text
		newChoice.focus_mode = Control.FOCUS_ALL
		choiceOptions.add_child(newChoice)
		newChoice.pressed.connect(_onDialogueChoiceSelected.bind(branch))

	# Wait a couple frames for UI to stabilize
	await get_tree().process_frame
	await get_tree().process_frame

	# Ensure first button is focused for keyboard/gamepad navigation
	if choiceOptions.get_child_count() > 0:
		choiceOptions.get_child(0).grab_focus()

	# Failsafe to ensure some button is focused
	await get_tree().process_frame
	if not get_viewport().gui_get_focus_owner():
		choiceOptions.get_child(0).grab_focus()

# Handles player selection of a dialogue choice and continues the dialogue.
func _onDialogueChoiceSelected(branch: DialogueBranch) -> void:
	var parentChoice := branch.get_parent()
	if parentChoice and parentChoice.has_method("chooseBranch"):
		parentChoice.chooseBranch(branch)

	choiceOptions.visible = false
	waitingForChoice = false
	dialogueItems = branch.getItems()
	dialogueItemIndex = 0

	dialogueUI.visible = true
	get_tree().paused = true
	
	if dialogueItems.size() == 0:
		hideDialogue()
	else:
		startDialogue()
