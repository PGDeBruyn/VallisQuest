class_name EnemyStateStun
extends EnemyState

@export var animationName: String = "stun"
@export var knockbackSpeed: float = 100.0
@export var decelerateSpeed: float = 50.0

@export_category("AI")
@export var nextState: EnemyState

var damagePosition: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var animationFinished: bool = false

# Initializes references and connects to damaged signal.
func init(_enemy: Enemy, _stateMachine: EnemyStateMachine) -> void:
	enemy = _enemy
	stateMachine = _stateMachine

	if not enemy.enemyDamaged.is_connected(onEnemyDamaged):
		enemy.enemyDamaged.connect(onEnemyDamaged)

# Prepares stun state, applies knockback, and starts animation.
func enter() -> void:
	enemy.invincible = true
	animationFinished = false

	if damagePosition != Vector2.ZERO:
		direction = (enemy.global_position - damagePosition).normalized()
	else:
		direction = Vector2.ZERO

	if direction != Vector2.ZERO:
		enemy.velocity = direction * knockbackSpeed
		enemy.setDirection(direction)
		print("Knockback velocity set to:", enemy.velocity)
	else:
		print("No knockback direction (zero vector)")

	enemy._updateAnimation(animationName)

	if not enemy.animPlayer.animation_finished.is_connected(onAnimationFinished):
		enemy.animPlayer.animation_finished.connect(onAnimationFinished)

# Cleans up stun state and resets invincibility and velocity.
func exit() -> void:
	enemy.invincible = false
	enemy.velocity = Vector2.ZERO

	if enemy.animPlayer.animation_finished.is_connected(onAnimationFinished):
		enemy.animPlayer.animation_finished.disconnect(onAnimationFinished)

# Handles knockback deceleration and transitions once animation ends.
func process(_delta: float) -> EnemyState:
	print("Current velocity:", enemy.velocity)
	if enemy.velocity.length() > 0:
		enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, decelerateSpeed * _delta)

	if animationFinished:
		return nextState

	return null

# Placeholder for physics behavior during stun.
func physics(_delta: float) -> EnemyState:
	return null

# Receives damage info and re-enters the stun state.
func onEnemyDamaged(hurtbox: Hurtbox) -> void:
	damagePosition = hurtbox.global_position
	stateMachine.changeState(self)

# Detects when the stun animation finishes.
func onAnimationFinished(anim_name: String) -> void:
	if anim_name.begins_with(animationName):
		animationFinished = true
