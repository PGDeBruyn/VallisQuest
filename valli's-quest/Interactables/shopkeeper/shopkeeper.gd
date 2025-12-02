@tool
class_name Shopkeeper
extends Node2D

@export var shopInventory: Array[ItemData] = []

@onready var dialogueBranchYes: DialogueBranch = $"Npc/DialogueInteraction/DialogueChoice/DialogueBranch"

func _ready() -> void:
	dialogueBranchYes.selected.connect(_onDialogueBranchYesSelected)

func _onDialogueBranchYesSelected() -> void:
	print("Showing shop menu")
	ShopMenu.showMenu(shopInventory)
