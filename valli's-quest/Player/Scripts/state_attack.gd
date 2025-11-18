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
	isAttacking = true
	player.isAttacking = true
	player.moveSpeedMultiplier = attackMoveMultiplier  # 🔹 slow down movement

	# Choose direction animation
	var dir := "up" if player.facing == Vector2.UP else "down" if player.facing == Vector2.DOWN else "side"
	var attackAnimName = "attack_%s" % dir

	# Play main animation (body) + sword effect
	player.playStateAnim("attack")
	if attackAnimation.has_animation(attackAnimName):
		print("Playing attack animation:", attackAnimName)
		attackAnimation.play(attackAnimName)
	else:
		print("Missing attack animation:", attackAnimName)

	# Play attack audio
	audio.stream = attackAudio
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()

	# Connect to animation_finished to detect attack end
	if not animationPlayer.animation_finished.is_connected(_onAttackAnimationFinished):
		animationPlayer.animation_finished.connect(_onAttackAnimationFinished)

	# Slight delay before hitbox becomes active
	await get_tree().create_timer(0.075).timeout
	if isAttacking:
		hurtbox.monitoring = true


func exit() -> void:
	isAttacking = false
	player.isAttacking = false
	hurtbox.monitoring = false
	player.moveSpeedMultiplier = 1.0  # 🔹 restore normal speed

	if animationPlayer.animation_finished.is_connected(_onAttackAnimationFinished):
		animationPlayer.animation_finished.disconnect(_onAttackAnimationFinished)


func process(delta: float) -> State:
	# Optional: small deceleration for smoother stop during swing
	player.velocity -= player.velocity * decelerateSpeed * delta

	# When attack ends, return to proper state
	if not isAttacking:
		if player.velocity == Vector2.ZERO:
			return idleState
		else:
			return walkState

	return null


func physics(_delta: float) -> State:
	return null


func handleInput(_event: InputEvent) -> State:
	return null


func _onAttackAnimationFinished(anim_name: String) -> void:
	if anim_name.begins_with("attack_"):
		isAttacking = false
