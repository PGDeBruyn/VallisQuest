class_name StateDeath
extends State

@export var exhaust_audio: AudioStream = preload("uid://ctjvtimmy3ees")
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

var miniTimer := 0.0
@export var deathDelay := 3.0
var canAcceptInput := false

func initState(playerRef: Player, stateMachineRef: PlayerStateMachine) -> void:
	player = playerRef
	stateMachine = stateMachineRef

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.isDead = true
	player.set_physics_process(false)

	player.animMain.play("death")
	audio.stream = exhaust_audio
	audio.play()
	AudioManager.playMusic(null)
	PlayerHud.show_game_over_screen()

	miniTimer = 0.0
	canAcceptInput = false

func process(delta: float) -> State:
	miniTimer += delta
	if miniTimer >= deathDelay:
		canAcceptInput = true
	return null

func exit() -> void:
	player.set_physics_process(true)
