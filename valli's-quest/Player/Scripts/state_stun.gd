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
	# Cache references to Idle and Death states for transitions
	var parent = get_parent()
	idleState = parent.get_node("Idle")
	deathState = parent.get_node("Death")

func initState(playerRef: Player, stateMachineRef: PlayerStateMachine) -> void:
	player = playerRef
	stateMachine = stateMachineRef
	# Listen for damage events to trigger stun
	player.damaged.connect(_onPlayerDamaged)

func enter() -> void:
	# Reset stun timer when entering stun state
	stunTimer = 0.0

	# Play stun animation
	player.playStateAnim("stun")

	if sourceHurtbox != null:
		# Apply knockback velocity away from damage source
		var knockbackDir = (player.global_position - sourceHurtbox.global_position).normalized()
		player.setExternalVelocity(knockbackDir * knockbackPower)
	else:
		player.clearExternalVelocity()

	# Play damage effect animation and grant temporary invincibility
	player.animEffect.play("damaged")
	player.grantInvulnerability(invincibilityDuration)

	# Disable player’s hitbox to prevent further damage during stun
	player.hitbox.monitoring = false

func process(delta: float) -> State:
	# Gradually reduce external velocity (knockback) over time
	if player.externalVelocityOverride != null:
		var newVel = player.externalVelocityOverride.move_toward(Vector2.ZERO, decelerationRate * delta)
		player.setExternalVelocity(newVel)

		# Clear velocity when slowed enough
		if newVel.length() < 1.0:
			player.clearExternalVelocity()

	stunTimer += delta

	# Transition to Death state if player health drops to zero or below
	if player.health <= 0:
		return deathState

	# After stun duration ends, return to Idle state
	if stunTimer >= stunDuration:
		return idleState

	# Stay in Stun state otherwise
	return null

func exit() -> void:
	# Re-enable player hitbox and clear velocity override on exit
	player.clearExternalVelocity()
	player.hitbox.monitoring = true

func physics(_delta: float) -> State:
	# No physics-specific logic needed in stun state
	return null

func handleInput(_event: InputEvent) -> State:
	# Ignore input while stunned
	return null

func _onPlayerDamaged(hurtbox: Hurtbox) -> void:
	# Update damage source reference
	sourceHurtbox = hurtbox

	# Switch to stun state if not already stunned
	if !(stateMachine.currentState is StateStun):
		stateMachine._changeState(self)
