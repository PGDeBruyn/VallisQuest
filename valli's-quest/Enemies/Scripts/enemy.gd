class_name Enemy
extends CharacterBody2D

signal directionChanged(new_direction: Vector2)
signal enemyDamaged(hurt_box: Hurtbox)
signal enemyDestroyed(hurt_box: Hurtbox)

const DIRECTIONS_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

@export var maxHp: int = 3
var hp: int

var facing: Vector2 = Vector2.DOWN
var invincible: bool = false
var isDead: bool = false  # Flag to stop physics after death

@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var stateMachine: EnemyStateMachine = $EnemyStateMachine
@onready var hitbox: Hitbox = $HitBox
@onready var player: Player = PlayerManager.player

# Initializes enemy health, state machine, and connects hitbox signals.
func _ready() -> void:
	hp = maxHp
	stateMachine.initialize(self)
	hitbox.damaged.connect(_onHit)

# Handles enemy movement, stops if dead or colliding, updates facing.
func _physics_process(_delta: float) -> void:
	if isDead:
		velocity = Vector2.ZERO
		return
	
	move_and_slide()
	
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		velocity = Vector2.ZERO
	
	_updateFacing()

# Moves enemy in specified direction at given speed.
func move_in_direction(dir: Vector2, speed: float) -> void:
	velocity = dir.normalized() * speed
	_updateFacing(dir)

# Stops enemy movement by zeroing velocity.
func stop() -> void:
	velocity = Vector2.ZERO

# Updates facing direction based on velocity or given direction.
func _updateFacing(newDir: Vector2 = Vector2.ZERO) -> void:
	if newDir == Vector2.ZERO:
		newDir = velocity
	if newDir.length() == 0:
		return
	
	var bestDir = _closestCardinalDirection(newDir)
	if bestDir != facing:
		facing = bestDir
		emit_signal("directionChanged", facing)
		sprite.scale.x = -1 if facing.x < 0 else 1
		_updateAnimation()

# Finds closest cardinal direction to the given vector.
func _closestCardinalDirection(dir: Vector2) -> Vector2:
	var directions = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	var maxDot = -1.0
	var chosenDir = Vector2.DOWN
	for d in directions:
		var dotVal = dir.normalized().dot(d)
		if dotVal > maxDot:
			maxDot = dotVal
			chosenDir = d
	return chosenDir

# Plays animation matching current facing and optional state.
func _updateAnimation(state: String = "") -> void:
	var suffix = ""
	if facing == Vector2.UP:
		suffix = "up"
	elif facing == Vector2.DOWN:
		suffix = "down"
	else:
		suffix = "side"
	
	var animName = state if state != "" else "idle"
	animPlayer.play(animName + "_" + suffix)

# Processes damage from hitbox, triggers death if hp reaches zero.
func _onHit(hurtbox: Hurtbox) -> void:
	if invincible or isDead:
		return
	
	hp = max(hp - hurtbox.damage, 0)
	emit_signal("enemyDamaged", hurtbox)
	
	if hp == 0:
		isDead = true
		emit_signal("enemyDestroyed", hurtbox)

# Heals enemy, not exceeding maximum health.
func heal(amount: int) -> void:
	hp = min(hp + amount, maxHp)

# Sets facing direction explicitly and updates animation if changed.
func setDirection(newDir: Vector2) -> void:
	newDir = newDir.normalized()
	if newDir == Vector2.ZERO:
		return
	
	var newFacing = _closestCardinalDirection(newDir)
	if newFacing != facing:
		facing = newFacing
		emit_signal("directionChanged", facing)
		sprite.scale.x = -1 if facing.x < 0 else 1
		_updateAnimation()
