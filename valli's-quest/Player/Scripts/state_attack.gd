class_name StateAttack
extends State

@export var attackAudio: AudioStream
@export_range(1, 20, 0.5) var decelerateSpeed: float = 5.0
@export var attackMoveMultiplier: float = 0.3  # percentage of speed during attack

var isAttacking: bool = false

@onready var walkState: State = $"../Walk"
@onready var idleState: State = $"../Idle"
@onready var animationPlayer: AnimationPlayer = $"../../AnimationPlayer"
@onready var attackAnimation: AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var hurtbox: Hurtbox = %AttackHurtBox


func enter() -> void:
	# Called when entering the attack state.
	isAttacking = true
	player.isAttacking = true

	# Reduce player movement speed while attacking.
	player.moveSpeedMultiplier = attackMoveMultiplier

	# Determine attack animation direction based on player's facing vector.
	var dir := "up" if player.facing == Vector2.UP else "down" if player.facing == Vector2.DOWN else "side"
	var attackAnimName = "attack_%s" % dir

	# Play main body attack animation.
	player.playStateAnim("attack")

	# Play corresponding attack effect animation if it exists.
	if attackAnimation.has_animation(attackAnimName):
		print("Playing attack animation:", attackAnimName)
		attackAnimation.play(attackAnimName)
	else:
		print("Missing attack animation:", attackAnimName)

	# Play attack sound with slight random pitch variation for variety.
	audio.stream = attackAudio
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()

	# Connect to animation_finished signal to detect when attack animation ends.
	if not animationPlayer.animation_finished.is_connected(_onAttackAnimationFinished):
		animationPlayer.animation_finished.connect(_onAttackAnimationFinished)

	# Delay activation of the hurtbox slightly to sync with animation.
	await get_tree().create_timer(0.075).timeout
	if isAttacking:
		hurtbox.monitoring = true


func exit() -> void:
	# Called when exiting the attack state.
	isAttacking = false
	player.isAttacking = false

	# Disable hurtbox detection and restore normal movement speed.
	hurtbox.monitoring = false
	player.moveSpeedMultiplier = 1.0

	# Disconnect from animation_finished signal to avoid duplicate calls.
	if animationPlayer.animation_finished.is_connected(_onAttackAnimationFinished):
		animationPlayer.animation_finished.disconnect(_onAttackAnimationFinished)


func process(delta: float) -> State:
	# Apply smooth deceleration to player's velocity during attack.
	player.velocity -= player.velocity * decelerateSpeed * delta

	# After attack finishes, transition to idle if stopped, else to walk.
	if not isAttacking:
		if player.velocity == Vector2.ZERO:
			return idleState
		else:
			return walkState

	return null


func physics(_delta: float) -> State:
	# No physics-specific logic in this state.
	return null


func handleInput(_event: InputEvent) -> State:
	# No input handling during attack.
	return null


func _onAttackAnimationFinished(anim_name: String) -> void:
	# Called when an animation finishes playing.
	# If the finished animation is an attack animation, end the attack.
	if anim_name.begins_with("attack_"):
		isAttacking = false
