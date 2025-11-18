class_name PlayerAbilities
extends Node

const BoomerangScene = preload("res://Player/boomerang.tscn")

enum Ability {
	NONE,
	BOOMERANG,
}

var selectedAbility: Ability = Ability.BOOMERANG
var playerRef: Player = null
var activeAbilityInstance: Node = null

signal ability_used(ability: Ability)

func _ready() -> void:
	playerRef = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ability"):
		match selectedAbility:
			Ability.BOOMERANG:
				_useBoomerang()

func _useBoomerang() -> void:
	if activeAbilityInstance:
		# Ability already active, don't spawn another
		return
	
	if playerRef == null:
		push_warning("Player reference missing in PlayerAbilities!")
		return

	# Instantiate boomerang and add to player's parent node
	var boom = BoomerangScene.instantiate()
	playerRef.get_parent().add_child(boom)
	boom.global_position = playerRef.global_position

	# Calculate throw direction — prefer movement velocity, fallback to facing
	var throwDir = Vector2.ZERO
	if playerRef.velocity.length_squared() > 0.01:
		throwDir = playerRef.velocity.normalized()
	else:
		throwDir = playerRef.facing

	# Connect to boomerang's caught signal to know when to clear active instance
	boom.caught.connect(Callable(self, "_onBoomerangCaught"))

	boom.launch(throwDir)
	activeAbilityInstance = boom

	emit_signal("ability_used", selectedAbility)

func _onBoomerangCaught():
	activeAbilityInstance = null
