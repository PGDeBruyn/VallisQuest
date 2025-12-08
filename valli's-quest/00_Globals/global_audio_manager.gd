extends Node
class_name GlobalAudioManager

@export var musicBus: String = "Music"
@export var musicFadeDuration: float = 0.5
@export var musicPlayerCount: int = 2

var _musicPlayers: Array[AudioStreamPlayer] = []
var _currentIndex: int = 0
var _hasPlayedBefore: bool = false

signal music_started(stream: AudioStream)
signal music_stopped(stream: AudioStream)

# Called when the node enters the scene tree; initializes music players
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initMusicPlayers()

# Creates and configures the pool of AudioStreamPlayers
func _initMusicPlayers() -> void:
	for i in musicPlayerCount:
		var player = AudioStreamPlayer.new()
		player.bus = musicBus
		player.volume_db = -40
		add_child(player)
		_musicPlayers.append(player)

# Plays the given music stream with crossfade handling
func playMusic(stream: AudioStream) -> void:
	if not stream:
		return
	
	var currentPlayer = _musicPlayers[_currentIndex]
	if currentPlayer.stream == stream:
		return 
	
	var oldPlayer = currentPlayer
	_currentIndex = (_currentIndex + 1) % musicPlayerCount
	currentPlayer = _musicPlayers[_currentIndex]
	currentPlayer.stream = stream
	
	_play_fade_in(currentPlayer)
	
	if _hasPlayedBefore:
		_fade_out_and_stop(oldPlayer)
	else:
		_hasPlayedBefore = true
	
	emit_signal("music_started", stream)

# Fades in the given player and starts playback
func _play_fade_in(player: AudioStreamPlayer) -> void:
	player.volume_db = -40
	player.play(0)
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0, musicFadeDuration)

# Fades out the given player and stops it when tween completes
func _fade_out_and_stop(player: AudioStreamPlayer) -> void:
	if not player.playing:
		return
	
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -40, musicFadeDuration)
	await tween.finished
	player.stop()
	emit_signal("music_stopped", player.stream)
