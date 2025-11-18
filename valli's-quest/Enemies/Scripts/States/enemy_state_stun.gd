# EnemyStateStun.gd
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

func init(_enemy: Enemy, _stateMachine: EnemyStateMachine) -> void:
	enemy = _enemy
	stateMachine = _stateMachine

	if not enemy.enemyDamaged.is_connected(onEnemyDamaged):
		enemy.enemyDamaged.connect(onEnemyDamaged)

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

func exit() -> void:
	enemy.invincible = false
	enemy.velocity = Vector2.ZERO

	if enemy.animPlayer.animation_finished.is_connected(onAnimationFinished):
		enemy.animPlayer.animation_finished.disconnect(onAnimationFinished)

func process(_delta: float) -> EnemyState:
	print("Current velocity:", enemy.velocity)
	if enemy.velocity.length() > 0:
		enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, decelerateSpeed * _delta)

	if animationFinished:
		return nextState

	return null

func physics(_delta: float) -> EnemyState:
	return null

func onEnemyDamaged(hurtbox: Hurtbox) -> void:
	damagePosition = hurtbox.global_position
	stateMachine.changeState(self)

func onAnimationFinished(anim_name: String) -> void:
	if anim_name.begins_with(animationName):
		animationFinished = true
