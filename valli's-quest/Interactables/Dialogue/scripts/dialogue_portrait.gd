@tool
class_name DialoguePortrait
extends Sprite2D

var blink: bool = false: set = _setBlink
var openMouth: bool = false: set = _setOpenMouth
var mouthOpenFrames: int = 0
var audio_pitch_base: float = 1.0

@onready var audioStreamPlayer: AudioStreamPlayer = $"../AudioStreamPlayer"

func _ready() -> void:
	# Connect to letter added signal and start blinking loop, skip if in editor
	if Engine.is_editor_hint():
		return
	DialogueSystem.letterAdded.connect(_checkMouthOpen)
	_blinker()

func _checkMouthOpen(letter: String) -> void:
	# Manage mouth open state and play audio based on letter type
	if 'aeiouy1234567890'.find(letter) >= 0:
		openMouth = true
		mouthOpenFrames += 3
		audioStreamPlayer.pitch_scale = randf_range(audio_pitch_base - 0.04, audio_pitch_base + 0.04)
		audioStreamPlayer.play()
	elif '.,!?'.find(letter) >= 0:
		audioStreamPlayer.pitch_scale = audio_pitch_base - 0.1
		audioStreamPlayer.play()
		mouthOpenFrames = 0
	if mouthOpenFrames > 0:
		mouthOpenFrames -= 1
	if mouthOpenFrames == 0 and openMouth:
		openMouth = false
		audioStreamPlayer.pitch_scale = randf_range(audio_pitch_base - 0.08, audio_pitch_base + 0.02)
		audioStreamPlayer.play()

func _updatePortrait() -> void:
	# Update sprite frame based on blink and mouth open states
	if openMouth:
		frame = 2
	else:
		frame = 0
	if blink:
		frame += 1

func _blinker() -> void:
	# Loop that toggles blink state with random timing when eyes closed and fixed timing when open
	if not blink:
		await get_tree().create_timer(randf_range(0.1, 3)).timeout
	else:
		await get_tree().create_timer(0.15).timeout
	blink = not blink
	_blinker()

func _setBlink(value: bool) -> void:
	# Setter for blink, updates portrait if changed
	if blink != value:
		blink = value
		_updatePortrait()

func _setOpenMouth(value: bool) -> void:
	# Setter for openMouth, updates portrait if changed
	if openMouth != value:
		openMouth = value
		_updatePortrait()
