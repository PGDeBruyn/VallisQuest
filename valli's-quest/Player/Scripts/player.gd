# player.gd
class_name Player
extends CharacterBody2D

signal facingChanged(direction: Vector2)
signal damaged(source: Hurtbox)

var facing: Vector2 = Vector2.DOWN
const DIRECTIONS = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

var health: int = 6
var maxHealth: int = 6
var invulnerable: bool = false
var isAttacking: bool = false   # Used by StateAttack to prevent animation override

@onready var animMain: AnimationPlayer = $AnimationPlayer
@onready var animEffect: AnimationPlayer = $EffectAnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var fsm: PlayerStateMachine = $StateMachine
@onready var hitbox: Hitbox = $HitBox
@onready var sfx: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D

var speed: float = 150.0
var moveSpeedMultiplier: float = 1.0  # 🔹 Allows states to modify move speed dynamically (used by attacks)
var externalVelocityOverride = null   # Can be assigned Vector2 or null
var initialMoveDirection: Vector2 = Vector2.ZERO  # Stores initial direction on movement start


func _ready() -> void:
	PlayerManager.player = self
	fsm.initialize(self)
	hitbox.damaged.connect(_onDamaged)
	_updateHealth(maxHealth)
	_updateAnimationOnIdle()


func _physics_process(_delta: float) -> void:
	# Apply external velocity override (knockback, stun, etc.)
	if externalVelocityOverride != null:
		velocity = externalVelocityOverride
	else:
		_getInput()

	# Apply movement speed modifier (used for attacks, slow effects, etc.)
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed * moveSpeedMultiplier

		# Determine how many direction buttons are pressed (for facing lock behavior)
		var numPressed = int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right")) + int(Input.is_action_pressed("up")) + int(Input.is_action_pressed("down"))

		if numPressed > 1:
			if initialMoveDirection == Vector2.ZERO:
				initialMoveDirection = velocity.normalized()
			_tryFaceDirection(initialMoveDirection)
		else:
			initialMoveDirection = velocity.normalized()
			_tryFaceDirection(initialMoveDirection)

		# Only update movement/idle animations if not stunned and not attacking
		if !(fsm.currentState is StateStun) and !isAttacking:
			_updateAnimationOnMovement()
	else:
		velocity = Vector2.ZERO
		initialMoveDirection = Vector2.ZERO
		if !(fsm.currentState is StateStun) and !isAttacking:
			_updateAnimationOnIdle()

	move_and_slide()


func _getInput() -> void:
	# Returns -1..1 for axes combined into a vector
	velocity = Input.get_vector("left", "right", "up", "down")


func _tryFaceDirection(dir: Vector2) -> void:
	var best_dir = DIRECTIONS[0]
	var best_dot = -1.0
	for d in DIRECTIONS:
		var dot = dir.dot(d)
		if dot > best_dot:
			best_dot = dot
			best_dir = d

	if best_dir != facing:
		facing = best_dir
		facingChanged.emit(facing)
		sprite.scale.x = -1 if facing.x < 0 else 1


func _updateAnimationOnMovement() -> void:
	playStateAnim("walk")


func _updateAnimationOnIdle() -> void:
	playStateAnim("idle")


func playStateAnim(state: String) -> void:
	# Build animation name from state + facing suffix
	var suffix: String
	match facing:
		Vector2.UP:
			suffix = "up"
		Vector2.DOWN:
			suffix = "down"
		_:
			suffix = "side"
	var anim_name = "%s_%s" % [state, suffix]
	if animMain.current_animation != anim_name:
		animMain.play(anim_name)


func _onDamaged(source: Hurtbox) -> void:
	if invulnerable:
		return

	_applyDamage(source.damage)
	damaged.emit(source)

	if health <= 0:
		_resetHealth()


func _applyDamage(amount: int) -> void:
	_updateHealth(health - amount)


func _resetHealth() -> void:
	_updateHealth(maxHealth)


func _updateHealth(newVal: int) -> void:
	print("updating HP")
	health = clampi(newVal, 0, maxHealth)
	PlayerHud.adjustHP(health, maxHealth)


func grantInvulnerability(time: float = 1.0) -> void:
	invulnerable = true
	var timer := get_tree().create_timer(time)
	await timer.timeout
	invulnerable = false


func setExternalVelocity(vel: Vector2) -> void:
	externalVelocityOverride = vel


func clearExternalVelocity() -> void:
	externalVelocityOverride = null

func setHealth(newHealth: int, newMaxHealth: int) -> void:
	_updateHealth(newHealth)
	maxHealth = newMaxHealth

func heal(amount: int) -> void:
	var newHealth = health + amount
	_updateHealth(newHealth)
