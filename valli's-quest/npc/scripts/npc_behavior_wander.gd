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
	# Skip initialization in the editor
	if Engine.is_editor_hint():
		return
	# Store the NPC's initial position as origin for wandering range calculations
	originPosition = npc.global_position
	# Remove collision shape if present, as wandering area may be handled differently
	if $CollisionShape2D:
		$CollisionShape2D.queue_free()
	# Call parent ready
	super()

func start() -> void:
	# Begin wandering routine only if NPC behavior is active
	if not npc.behaviorActive:
		return
	# Start the asynchronous wander loop deferred to avoid blocking
	call_deferred("_wanderRoutine")

func stop() -> void:
	# Stopping behavior: no direct cancellation implemented
	# Loop relies on npc.behaviorActive flag to exit
	pass

func _wanderRoutine() -> void:
	# Main loop for wandering while behavior is active
	while npc.behaviorActive:
		# Idle phase: NPC stands still and plays idle animation
		npc.state = "idle"
		npc.velocity = Vector2.ZERO
		npc._updateAnimation()
		# Wait for a randomized idle duration
		await get_tree().create_timer(idleTime * (0.5 + randf())).timeout

		if not npc.behaviorActive:
			break

		# Wander phase: NPC picks a random cardinal direction to walk
		npc.state = "walk"
		var direction = DIRECTIONS[randi() % DIRECTIONS.size()]
		npc.facingDirection = direction
		npc.velocity = direction * wanderSpeed
		npc._setFacingName()
		npc._updateAnimation()
		# Wait for a randomized wander duration
		await get_tree().create_timer(wanderTime * (0.5 + randf())).timeout

	# When behavior is deactivated, stop moving and reset animation to idle
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc._updateAnimation()

func setWanderRange(value: int) -> void:
	# Update the wanderRange property
	wanderRange = value
	# If a collision shape exists, update its radius to match the new wander range
	if $CollisionShape2D and $CollisionShape2D.shape:
		$CollisionShape2D.shape.radius = wanderRange * 32
