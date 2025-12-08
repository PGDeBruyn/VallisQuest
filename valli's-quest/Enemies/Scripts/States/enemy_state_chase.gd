class_name EnemyStateChase
extends EnemyState

@export var animationName: String = "chase"
@export var maxSpeed: float = 40.0
@export var rotationSpeed: float = 5.0
@export var aggroTimeout: float = 0.5

@export_category("AI")
@export var visionArea: VisionArea
@export var attackArea: Hurtbox
@export var fallbackState: EnemyState

var aggroTimer: float = 0.0
var currentDirection: Vector2 = Vector2.DOWN
var playerVisible: bool = false

# Assigns enemy and state machine references and connects vision signals.
func init(_enemy: Enemy, _stateMachine: EnemyStateMachine) -> void:
	enemy = _enemy
	stateMachine = _stateMachine

	if visionArea:
		visionArea.player_spotted.connect(Callable(self, "_onPlayerSpotted"))
		visionArea.player_lost.connect(Callable(self, "_onPlayerLost"))

# Prepares chase behavior and enables attack hit detection.
func enter() -> void:
	aggroTimer = aggroTimeout
	_updateEnemyAnimation()
	if attackArea:
		attackArea.monitoring = true

# Cleans up when leaving the chase state.
func exit() -> void:
	if attackArea:
		attackArea.monitoring = false
	playerVisible = false

# Handles chasing logic and determines when to stop chasing.
func process(delta: float) -> EnemyState:
	var player = PlayerManager.player
	if player == null:
		return null

	if player.isDead:
		playerVisible = false
		enemy.velocity = Vector2.ZERO
		return fallbackState

	_updateAggroTimer(delta)

	if playerVisible:
		var targetDir = (player.global_position - enemy.global_position).normalized()
		currentDirection = _rotateTowards(currentDirection, targetDir, rotationSpeed * delta)
		enemy.velocity = currentDirection * maxSpeed
	else:
		enemy.velocity = Vector2.ZERO

	enemy.setDirection(currentDirection)
	_updateEnemyAnimation()

	if aggroTimer <= 0.0:
		return fallbackState

	return null

# Allows physics-specific chase logic if needed.
func physics(_delta: float) -> EnemyState:
	return null

# Updates the timer governing how long the enemy remains aggro after losing sight.
func _updateAggroTimer(delta: float) -> void:
	if playerVisible:
		aggroTimer = aggroTimeout
	else:
		aggroTimer -= delta

# Smoothly rotates the enemy toward its target direction.
func _rotateTowards(current: Vector2, target: Vector2, maxRadiansDelta: float) -> Vector2:
	if current == Vector2.ZERO:
		return target

	var angleCurrent = current.angle()
	var angleTarget = target.angle()
	var angleDiff = wrapf(angleTarget - angleCurrent, -PI, PI)
	var angleChange = clamp(angleDiff, -maxRadiansDelta, maxRadiansDelta)
	var newAngle = angleCurrent + angleChange
	return Vector2(cos(newAngle), sin(newAngle))

# Updates the enemy’s animation to match chase behavior.
func _updateEnemyAnimation() -> void:
	enemy._updateAnimation(animationName)

# Triggered when the player enters the vision area.
func _onPlayerSpotted() -> void:
	var player = PlayerManager.player
	if player == null:
		return

	if player.isDead:
		playerVisible = false
		return

	playerVisible = true
	if stateMachine.currentState is EnemyStateStun or stateMachine.currentState is EnemyStateDestroy:
		return
	stateMachine.changeState(self)

# Triggered when the player leaves the vision area.
func _onPlayerLost() -> void:
	playerVisible = false
