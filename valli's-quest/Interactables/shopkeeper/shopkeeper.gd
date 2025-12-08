@tool
class_name Shopkeeper
extends Node2D

@export var shopInventory: Array[ItemData] = []  # Items available in the shop

@onready var dialogueBranchYes: DialogueBranch = $"Npc/DialogueInteraction/DialogueChoice/DialogueBranch"  # Reference to the 'Yes' dialogue branch

func _ready() -> void:
	# Connect the selected signal to handle when the player chooses 'Yes' in dialogue
	dialogueBranchYes.selected.connect(_onDialogueBranchYesSelected)

func _onDialogueBranchYesSelected() -> void:
	# Trigger the shop menu display with the current shop inventory
	print("Showing shop menu")
	ShopMenu.showMenu(shopInventory)
