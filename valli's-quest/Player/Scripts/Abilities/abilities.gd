class_name PlayerAbilities
extends Node

# Preload the Boomerang scene to instantiate when used
const BoomerangScene = preload("res://Player/boomerang.tscn")

# Enum defining possible player abilities
enum Ability {
	NONE,
	BOOMERANG,
}

# Currently selected ability (default to Boomerang)
var selectedAbility: Ability = Ability.BOOMERANG

# Reference to the player node
var playerRef: Player = null

# Instance of the active ability (e.g., the boomerang object)
var activeAbilityInstance: Node = null

# Signal emitted when an ability is used, passes which ability was used
signal ability_used(ability: Ability)

func _ready() -> void:
	# Get player reference from PlayerManager
	playerRef = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	# Listen for input action to use the ability
	if event.is_action_pressed("ability"):
		match selectedAbility:
			Ability.BOOMERANG:
				_useBoomerang()

func _useBoomerang() -> void:
	# Prevent multiple active boomerangs at the same time
	if activeAbilityInstance:
		return
	
	if playerRef == null:
		push_warning("Player reference missing in PlayerAbilities!")
		return

	# Instantiate and add the boomerang to the player's parent node
	var boom = BoomerangScene.instantiate()
	playerRef.get_parent().add_child(boom)
	boom.global_position = playerRef.global_position

	# Determine throw direction based on player velocity or facing direction
	var throwDir = Vector2.ZERO
	if playerRef.velocity.length_squared() > 0.01:
		throwDir = playerRef.velocity.normalized()
	else:
		throwDir = playerRef.facing

	# Connect to boomerang's caught signal to clear active ability reference when caught
	boom.caught.connect(Callable(self, "_onBoomerangCaught"))

	# Launch the boomerang in the calculated direction
	boom.launch(throwDir)
	activeAbilityInstance = boom

	# Emit signal that an ability was used
	emit_signal("ability_used", selectedAbility)

func _onBoomerangCaught():
	# Clear the active ability instance when the boomerang is caught
	activeAbilityInstance = null
