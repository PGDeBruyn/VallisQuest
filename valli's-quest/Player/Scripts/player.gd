class_name Player
extends CharacterBody2D

signal facingChanged(direction: Vector2)  # Emitted when player facing direction changes
signal damaged(source: Hurtbox)            # Emitted when player takes damage
signal died()                              # Emitted when player dies (health reaches 0)
signal revived()                           # Emitted when player is revived

var facing: Vector2 = Vector2.DOWN         # Current facing direction
const DIRECTIONS = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]  # Allowed facing directions

var health: int = 6
var maxHealth: int = 6
var invulnerable: bool = false             # Flag for temporary invulnerability
var isAttacking: bool = false               # Flag to indicate if attacking
var isDead: bool = false                    # Flag to indicate if dead

@onready var animMain: AnimationPlayer = $AnimationPlayer
@onready var animEffect: AnimationPlayer = $EffectAnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var fsm: PlayerStateMachine = $StateMachine
@onready var hitbox: Hitbox = $HitBox
@onready var sfx: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D

var speed: float = 150.0                    # Base movement speed
var moveSpeedMultiplier: float = 1.0       # Multiplier for movement speed (e.g., buffs/debuffs)
var externalVelocityOverride = null         # Overrides movement velocity (for knockback, stun, etc.)
var initialMoveDirection: Vector2 = Vector2.ZERO  # Stores initial move direction for diagonal input

func _ready() -> void:
	# Called when the player node is ready
	PlayerManager.player = self             # Register self as the player in manager
	fsm.initialize(self)                    # Initialize the player's state machine
	hitbox.damaged.connect(_onDamaged)     # Connect to damage signal from hitbox
	_updateHealth(maxHealth)                # Set health to max on start
	_updateAnimationOnIdle()                # Set initial idle animation

func _physics_process(_delta: float) -> void:
	# Main physics update loop for player movement and state
	if externalVelocityOverride != null:
		# If an external velocity override is set (e.g., knockback), apply it directly
		velocity = externalVelocityOverride
	else:
		_getInput()  # Otherwise, read player input for movement

	# Normalize and apply speed to velocity if moving
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed * moveSpeedMultiplier

		# Check how many directional keys are pressed
		var numPressed = int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right")) + int(Input.is_action_pressed("up")) + int(Input.is_action_pressed("down"))

		if numPressed > 1:
			# Multiple keys pressed (diagonal movement)
			if initialMoveDirection == Vector2.ZERO:
				initialMoveDirection = velocity.normalized()
			_tryFaceDirection(initialMoveDirection)
		else:
			# Single key pressed or none, update facing to current direction
			initialMoveDirection = velocity.normalized()
			_tryFaceDirection(initialMoveDirection)

		# Update movement animation if not stunned and not attacking
		if !(fsm.currentState is StateStun) and !isAttacking:
			_updateAnimationOnMovement()
	else:
		# No movement input
		velocity = Vector2.ZERO
		initialMoveDirection = Vector2.ZERO
		if !(fsm.currentState is StateStun) and !isAttacking:
			_updateAnimationOnIdle()

	move_and_slide()  # Perform actual movement using Godot's built-in method

func _getInput() -> void:
	# Get directional input vector from action map
	velocity = Input.get_vector("left", "right", "up", "down")

func _tryFaceDirection(dir: Vector2) -> void:
	# Set facing direction based on closest cardinal direction to input
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
		# Flip sprite horizontally if facing left
		sprite.scale.x = -1 if facing.x < 0 else 1

func _updateAnimationOnMovement() -> void:
	# Play walking animation for current facing
	playStateAnim("walk")

func _updateAnimationOnIdle() -> void:
	# Play idle animation for current facing
	playStateAnim("idle")

func playStateAnim(state: String) -> void:
	# Play an animation named "<state>_<direction>", e.g. "walk_up"
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

# --- Damage handling ---

func _onDamaged(source: Hurtbox) -> void:
	# Called when the player takes damage from a Hurtbox
	print("Damage received. Invulnerable:", invulnerable, "Dead:", isDead)
	if invulnerable or isDead:
		print("Ignoring damage due to invulnerable or dead state")
		return
	_applyDamage(source.damage)
	damaged.emit(source)

	# IMPORTANT: Do not auto-reset health here.
	# Let the Stun state handle health <= 0 and trigger death to avoid instant-refill bugs.

func _applyDamage(amount: int) -> void:
	# Subtract damage amount from current health
	_updateHealth(health - amount)

func _updateHealth(newVal: int) -> void:
	# Clamp and update health, update HUD, emit died if health reaches zero
	print("updating HP")
	health = clampi(newVal, 0, maxHealth)
	PlayerHud.adjustHP(health, maxHealth)

	if health <= 0 and not isDead:
		isDead = true
		emit_signal("died")

func grantInvulnerability(time: float = 1.0) -> void:
	# Temporarily make player invulnerable for 'time' seconds
	invulnerable = true
	var timer := get_tree().create_timer(time)
	await timer.timeout
	invulnerable = false

# External velocity helpers (used by stun/knockback)
func setExternalVelocity(vel: Vector2) -> void:
	# Set an external velocity override for movement (e.g., knockback)
	externalVelocityOverride = vel

func clearExternalVelocity() -> void:
	# Clear any external velocity override, resume normal movement
	externalVelocityOverride = null

# Utility: set health and maxHealth together
func setHealth(newHealth: int, newMaxHealth: int) -> void:
	_updateHealth(newHealth)
	maxHealth = newMaxHealth

func heal(amount: int) -> void:
	# Increase health by amount, capped by maxHealth
	_updateHealth(health + amount)

# Called when reviving from Death (respawn)
func revivePlayer() -> void:
	_updateHealth(maxHealth)

	# Reset death state to allow taking damage again
	isDead = false

	# Give short invulnerability window after revival
	grantInvulnerability(1.0)

	emit_signal("revived")

	# Attempt to set FSM state to Idle after revival
	var idleState := fsm.findStateByClassOrName("StateIdle", "Idle")
	if idleState:
		fsm.changeState(idleState)
