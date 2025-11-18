# EnemyStateDestroy.gd
class_name EnemyStateDestroy
extends EnemyState

const PICKUP = preload("res://Items/ItemPickup/item_pickup.tscn")

@export var animationName: String = "destroy"
@export var knockbackSpeed: float = 100.0
@export var decelerateSpeed: float = 10.0

@export_category("AI")
@export_category("Item Drops")
@export var drops: Array[DropData]

var damagePosition: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var isDestroying: bool = false

func init(_enemy: Enemy, _stateMachine: EnemyStateMachine) -> void:
	enemy = _enemy
	stateMachine = _stateMachine
	if not enemy.enemyDestroyed.is_connected(onEnemyDestroyed):
		enemy.enemyDestroyed.connect(onEnemyDestroyed)

func enter() -> void:
	disableHurtBox()
	isDestroying = false
	enemy.invincible = true

	if damagePosition != Vector2.ZERO:
		direction = (enemy.global_position - damagePosition).normalized()
	else:
		direction = Vector2.ZERO

	if direction != Vector2.ZERO:
		enemy.setDirection(direction)
		enemy.velocity = direction * knockbackSpeed
	else:
		enemy.velocity = Vector2.ZERO

	enemy._updateAnimation(animationName)

	if not enemy.animPlayer.animation_finished.is_connected(onAnimationFinished):
		enemy.animPlayer.animation_finished.connect(onAnimationFinished)

	disableHurtBox()
	dropItems()

func exit() -> void:
	enemy.velocity = Vector2.ZERO

	if enemy.animPlayer.animation_finished.is_connected(onAnimationFinished):
		enemy.animPlayer.animation_finished.disconnect(onAnimationFinished)

func process(delta: float) -> EnemyState:
	if isDestroying:
		enemy.velocity = Vector2.ZERO
		return null

	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, decelerateSpeed * delta)
	return null

func physics(_delta: float) -> EnemyState:
	return null

func onEnemyDestroyed(hurtbox: Hurtbox) -> void:
	damagePosition = hurtbox.global_position
	stateMachine.changeState(self)

func onAnimationFinished(anim_name: String) -> void:
	if anim_name.begins_with(animationName):
		isDestroying = true
		enemy.velocity = Vector2.ZERO
		enemy.queue_free()

func disableHurtBox() -> void:
	var hurtBox: Hurtbox = enemy.get_node_or_null("Hurtbox")
	if hurtBox:
		hurtBox.monitoring = false

func dropItems() -> void:
	if drops.size() == 0:
		return

	var validDrops: Array = []
	for d in drops:
		if d != null and d.item != null:
			validDrops.append(d)

	var spawnQueue: Array = []
	for dropData in validDrops:
		var count = dropData.getDropCount()
		for _i in range(count):
			spawnQueue.append(dropData.item)

	spawnQueue.shuffle()

	for item in spawnQueue:
		var dropInstance = PICKUP.instantiate() as ItemPickup
		dropInstance.itemData = item
		enemy.get_parent().call_deferred("add_child", dropInstance)

		var offset = Vector2(randf_range(-16, 16), randf_range(-16, 16))
		dropInstance.global_position = enemy.global_position + offset

		var angleOffset = randf_range(-PI * 0.75, PI * 0.75)
		var speedMultiplier = randf_range(150, 300)
		dropInstance.velocity = enemy.velocity.rotated(angleOffset).normalized() * speedMultiplier
