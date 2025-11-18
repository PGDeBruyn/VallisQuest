class_name StateStun
extends State

@export var knockbackPower: float = 200.0
@export var decelerationRate: float = 500.0  # How fast knockback slows down
@export var stunDuration: float = 0.3        # How long the stun lasts
@export var invincibilityDuration: float = 1.0

var sourceHurtbox: Hurtbox = null
var idleState: State = null
var stunTimer: float = 0.0

func _ready() -> void:
	idleState = get_parent().get_node("Idle")

func initState(playerRef: Player, stateMachineRef: PlayerStateMachine) -> void:
	player = playerRef
	stateMachine = stateMachineRef
	player.damaged.connect(_onPlayerDamaged)

func enter() -> void:
	stunTimer = 0.0

	# Play stun animation based on facing
	player.playStateAnim("stun")

	# Apply knockback velocity if we have a source
	if sourceHurtbox != null:
		var knockbackDir = (player.global_position - sourceHurtbox.global_position).normalized()
		player.setExternalVelocity(knockbackDir * knockbackPower)
	else:
		player.clearExternalVelocity()

	# Play damage effect and grant temporary invulnerability
	player.animEffect.play("damaged")
	player.grantInvulnerability(invincibilityDuration)
	player.hitbox.monitoring = false

func process(delta: float) -> State:
	# If player has external velocity (knockback), decelerate it
	if player.externalVelocityOverride != null:
		var newVel = player.externalVelocityOverride.move_toward(Vector2.ZERO, decelerationRate * delta)
		player.setExternalVelocity(newVel)

		if newVel.length() < 1.0:
			player.clearExternalVelocity()

	# Count stun time
	stunTimer += delta
	if stunTimer >= stunDuration:
		return idleState

	return null

func exit() -> void:
	player.clearExternalVelocity()
	player.hitbox.monitoring = true
	print("StateStun: Exiting stun state, resuming control")

func physics(_delta: float) -> State:
	return null

func handleInput(_event: InputEvent) -> State:
	# No input allowed during stun
	return null

func _onPlayerDamaged(hurtbox: Hurtbox) -> void:
	sourceHurtbox = hurtbox
	print("StateStun: Player damaged, switching to stun state")
	
	# Only change to stun if not already stunned
	if !(stateMachine.currentState is StateStun):
		stateMachine._changeState(self)
