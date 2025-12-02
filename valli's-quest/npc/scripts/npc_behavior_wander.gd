@tool
class_name WanderBehavior
extends NPCBehavior

const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

@export var wanderRange: int = 2: set = setWanderRange
@export var wanderSpeed: float = 30.0
@export var wanderTime: float = 1.0
@export var idleTime: float = 1.0

var originPosition: Vector2

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	originPosition = npc.global_position
	if $CollisionShape2D:
		$CollisionShape2D.queue_free()
	super()

func start() -> void:
	if not npc.behaviorActive:
		return
	call_deferred("_wanderRoutine")  # run async

func stop() -> void:
	# No direct cancellation available, rely on behaviorActive flag
	pass

func _wanderRoutine() -> void:
	while npc.behaviorActive:
		# Idle phase
		npc.state = "idle"
		npc.velocity = Vector2.ZERO
		npc._updateAnimation()
		await get_tree().create_timer(idleTime * (0.5 + randf())).timeout

		if not npc.behaviorActive:
			break

		# Wander phase
		npc.state = "walk"
		var direction = DIRECTIONS[randi() % DIRECTIONS.size()]
		npc.facingDirection = direction
		npc.velocity = direction * wanderSpeed
		npc._setFacingName()
		npc._updateAnimation()
		await get_tree().create_timer(wanderTime * (0.5 + randf())).timeout

	# Stop moving after loop ends
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc._updateAnimation()

func setWanderRange(value: int) -> void:
	wanderRange = value
	if $CollisionShape2D and $CollisionShape2D.shape:
		$CollisionShape2D.shape.radius = wanderRange * 32
