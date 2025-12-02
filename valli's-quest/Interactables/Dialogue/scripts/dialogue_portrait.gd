@tool
class_name DialoguePortrait
extends Sprite2D

var blink: bool = false: set = _setBlink
var openMouth: bool = false: set = _setOpenMouth
var mouthOpenFrames: int = 0
var audio_pitch_base: float = 1.0

@onready var audioStreamPlayer: AudioStreamPlayer = $"../AudioStreamPlayer"

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	DialogueSystem.letterAdded.connect(_checkMouthOpen)
	_blinker()

func _checkMouthOpen(letter: String) -> void:
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
	if openMouth:
		frame = 2
	else:
		frame = 0
	if blink:
		frame += 1

func _blinker() -> void:
	if not blink:
		await get_tree().create_timer(randf_range(0.1, 3)).timeout
	else:
		await get_tree().create_timer(0.15).timeout
	blink = not blink
	_blinker()

func _setBlink(value: bool) -> void:
	if blink != value:
		blink = value
		_updatePortrait()

func _setOpenMouth(value: bool) -> void:
	if openMouth != value:
		openMouth = value
		_updatePortrait()
