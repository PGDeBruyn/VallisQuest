class_name ItemEffectHeal
extends ItemEffect

@export var healAmount: int = 1      # Amount of health to restore
@export var audio: AudioStream       # Audio to play on heal

static var action_stack := []        # Stack to keep track of heal actions for undo

func use() -> void:
	# Create an action dictionary representing this heal use
	var action = {
		"amount": healAmount,
		"audio": audio,
		"applied": false,
		"apply": null,
		"rollback": null,
	}

	# Define the apply lambda: heals the player and plays audio if any
	action["apply"] = func() -> void:
		if action["applied"]:
			return
		var player = PlayerManager.player
		if player != null:
			player.heal(action["amount"])
			if action["audio"] != null:
				PauseMenu.playAudio(action["audio"])
		action["applied"] = true

	# Define the rollback lambda: undoes the heal by damaging the player
	action["rollback"] = func() -> void:
		if not action["applied"]:
			return
		var player = PlayerManager.player
		if player != null:
			player.damage(action["amount"])  # Undo heal by damage
		action["applied"] = false

	# Store the action on the stack and immediately apply it
	action_stack.append(action)
	action["apply"].call()

static func undo_last() -> void:
	# Undo the most recent heal action if any exist
	if action_stack.size() == 0:
		return
	var last_action = action_stack.pop_back()
	last_action["rollback"].call()
