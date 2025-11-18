# EnemyStateWander.gd
class_name EnemyStateWander
extends EnemyState

@export var animationName: String = "walk"
@export var wanderSpeed: float = 20.0

@export_category("AI")
@export var minCycles: int = 1
@export var maxCycles: int = 4
@export var cycleDuration: float = 0.75
@export var nextStatePath: NodePath

var timer: Timer
var currentCycle: int = 0
var totalCycles: int = 0
var direction: Vector2
var nextState: EnemyState = null

func _ready() -> void:
	if nextStatePath != null and nextStatePath != NodePath(""):
		nextState = get_node_or_null(nextStatePath)

func init(_enemy: Enemy, _stateMachine: EnemyStateMachine) -> void:
	enemy = _enemy
	stateMachine = _stateMachine

	if timer == null:
		timer = Timer.new()
		timer.one_shot = true
		enemy.add_child(timer)
		timer.connect("timeout", Callable(self, "_on_cycle_complete"))

func enter() -> void:
	totalCycles = randi_range(minCycles, maxCycles)
	currentCycle = 0
	_start_cycle()

func exit() -> void:
	if timer and timer.is_stopped() == false:
		timer.stop()
	enemy.velocity = Vector2.ZERO

func _start_cycle() -> void:
	var directions = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	direction = directions[randi() % directions.size()]
	enemy.velocity = direction * wanderSpeed
	enemy.setDirection(direction)
	enemy._updateAnimation(animationName)
	timer.wait_time = cycleDuration
	timer.start()

func _on_cycle_complete() -> void:
	currentCycle += 1
	if currentCycle < totalCycles:
		_start_cycle()
	else:
		if nextState:
			stateMachine.changeState(nextState)

func process(_delta: float) -> EnemyState:
	return null

func physics(_delta: float) -> EnemyState:
	return null
