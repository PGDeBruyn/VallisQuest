class_name StateStun
extends State

@export var knockbackPower: float = 200.0
@export var decelerationRate: float = 500.0
@export var stunDuration: float = 0.3
@export var invincibilityDuration: float = 1.0

var sourceHurtbox: Hurtbox = null
var stunTimer: float = 0.0

var idleState: State
var deathState: State

func _ready() -> void:
	# Pick these up from the state machine reliably
	var parent = get_parent()
	idleState = parent.get_node("Idle")
	deathState = parent.get_node("Death")

func initState(playerRef: Player, stateMachineRef: PlayerStateMachine) -> void:
	player = playerRef
	stateMachine = stateMachineRef
	player.damaged.connect(_onPlayerDamaged)

func enter() -> void:
	stunTimer = 0.0

	player.playStateAnim("stun")

	if sourceHurtbox != null:
		var knockbackDir = (player.global_position - sourceHurtbox.global_position).normalized()
		player.setExternalVelocity(knockbackDir * knockbackPower)
	else:
		player.clearExternalVelocity()

	player.animEffect.play("damaged")
	player.grantInvulnerability(invincibilityDuration)
	player.hitbox.monitoring = false

func process(delta: float) -> State:
	if player.externalVelocityOverride != null:
		var newVel = player.externalVelocityOverride.move_toward(Vector2.ZERO, decelerationRate * delta)
		player.setExternalVelocity(newVel)

		if newVel.length() < 1.0:
			player.clearExternalVelocity()

	stunTimer += delta

	# DEATH CHECK ADDED BACK
	if player.health <= 0:
		return deathState

	if stunTimer >= stunDuration:
		return idleState

	return null

func exit() -> void:
	player.clearExternalVelocity()
	player.hitbox.monitoring = true

func physics(_delta: float) -> State:
	return null

func handleInput(_event: InputEvent) -> State:
	return null

func _onPlayerDamaged(hurtbox: Hurtbox) -> void:
	sourceHurtbox = hurtbox
	if !(stateMachine.currentState is StateStun):
		stateMachine._changeState(self)
