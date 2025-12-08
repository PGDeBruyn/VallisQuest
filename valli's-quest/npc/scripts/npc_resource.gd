class_name NPCResource
extends Resource

# The display name of the NPC
@export var npcName: String = ""

# The main sprite texture used for the NPC in the game world
@export var sprite: Texture

# The portrait texture used in dialogue UI or similar interfaces
@export var portrait: Texture

# The pitch modifier applied to NPC dialogue audio, allowing variation in voice tone
# Range limited between 0.5 and 1.8, with step increments of 0.02
@export_range(0.5, 1.8, 0.02) var dialogueAudioPitch: float = 1.0
