class_name StateDeath
extends State

@export var exhaust_audio: AudioStream = preload("uid://ctjvtimmy3ees")
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

var miniTimer := 0.0
@export var deathDelay := 3.0
var canAcceptInput := false

func initState(playerRef: Player, stateMachineRef: PlayerStateMachine) -> void:
	# Initialize references to player and state machine
	player = playerRef
	stateMachine = stateMachineRef

func enter() -> void:
	# Called when entering the Death state.
	# Stop player movement and mark as dead
	player.velocity = Vector2.ZERO
	player.isDead = true
	player.set_physics_process(false)

	# Play death animation and death sound
	player.animMain.play("death")
	audio.stream = exhaust_audio
	audio.play()

	# Stop any background music
	AudioManager.playMusic(null)

	# Show Game Over screen UI
	PlayerHud.show_game_over_screen()

	# Reset timer and input flag
	miniTimer = 0.0
	canAcceptInput = false

func process(delta: float) -> State:
	# Increment timer each frame
	miniTimer += delta

	# Enable input acceptance after delay has passed
	if miniTimer >= deathDelay:
		canAcceptInput = true

	return null  # No state change during death animation

func exit() -> void:
	# Restore player physics processing when exiting Death state
	player.set_physics_process(true)
