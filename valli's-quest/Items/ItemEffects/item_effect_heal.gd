class_name ItemEffectHeal
extends ItemEffect

@export var healAmount: int = 1
@export var audio: AudioStream

static var action_stack := []

func use() -> void:
	var action = {
		"amount": healAmount,
		"audio": audio,
		"applied": false,
		"apply": null,
		"rollback": null,
	}

	# Assign lambdas now that 'action' exists
	action["apply"] = func() -> void:
		if action["applied"]:
			return
		var player = PlayerManager.player
		if player != null:
			player.heal(action["amount"])
			if action["audio"] != null:
				PauseMenu.play_audio(action["audio"])
		action["applied"] = true

	action["rollback"] = func() -> void:
		if not action["applied"]:
			return
		var player = PlayerManager.player
		if player != null:
			player.damage(action["amount"])  # Undo heal by damage
		action["applied"] = false

	action_stack.append(action)
	action["apply"].call()

static func undo_last() -> void:
	if action_stack.size() == 0:
		return
	var last_action = action_stack.pop_back()
	last_action["rollback"].call()
