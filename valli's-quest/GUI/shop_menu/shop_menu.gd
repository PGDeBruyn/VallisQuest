@tool
extends CanvasLayer

signal purchaseRequested(item: ItemData)
signal purchaseFailed(item: ItemData)
signal menuShown()
signal menuHidden()

const SHOP_ITEM_BUTTON = preload("uid://kl385fwgnb4c")

@export var currencyItem: ItemData = preload("uid://k2qctr6hbx5s")

@onready var closeButton: Button = %CloseButton
@onready var audioPlayer: AudioStreamPlayer = $AudioStreamPlayer
@onready var shopItemsContainer: VBoxContainer = %ShopItemsContainer
@onready var gemsLabel: Label = %Label
@onready var gemAnimationPlayer: AnimationPlayer = $Control/PanelContainer2/AnimationPlayer
@onready var itemImage: TextureRect = %ItemImage
@onready var itemNameLabel: Label = %ItemName
@onready var itemDescriptionLabel: Label = %ItemDescription2
@onready var itemCostLabel: Label = $Control/Details/Control/Label2
@onready var itemOwnedLabel: Label = $Control/Details/Control/Label

var isActive := false
var currentItems: Array[ItemData] = []
var lastFocusedButton: ShopItemButton = null

func _ready() -> void:
	# Set process mode and connect signals
	process_mode = Node.PROCESS_MODE_ALWAYS

	closeButton.pressed.connect(_onCloseButtonPressed)
	audioPlayer.finished.connect(_onAudioFinished)

	hideMenu()

func showMenu(items: Array[ItemData]) -> void:
	# Show shop menu, pause game if no dialogue active, and update UI
	isActive = true
	visible = true
	if not DialogueSystem.isActive:
		get_tree().paused = true

	currentItems = items.duplicate()

	_refreshShopItems()
	_updateGems()
	_selectFirstItem()

	menuShown.emit()

func hideMenu() -> void:
	# Hide shop menu, unpause game, clear UI, and emit signal
	isActive = false
	visible = false
	get_tree().paused = false
	_clearShopItems()
	menuHidden.emit()

func _onCloseButtonPressed() -> void:
	# Close button callback to hide menu
	hideMenu()

func _refreshShopItems() -> void:
	# Clear and rebuild shop item buttons from current items
	_clearShopItems()
	print("Refreshing shop items, count: ", currentItems.size())

	for item in currentItems:
		var btn: ShopItemButton = SHOP_ITEM_BUTTON.instantiate()
		btn.setupItem(item)
		btn.show()

		btn.pressed.connect(_onShopItemPressed.bind(btn))
		btn.focus_entered.connect(_onShopItemFocused.bind(btn))

		shopItemsContainer.add_child(btn)
		print("Added button for item: ", item.name)

func _clearShopItems() -> void:
	# Remove all shop item buttons from container
	for child in shopItemsContainer.get_children():
		child.queue_free()

func _updateGems() -> void:
	# Update gems label to show current currency amount
	if currencyItem != null:
		var qty = get_item_quantity(currencyItem)
		gemsLabel.text = str(qty)
	else:
		gemsLabel.text = "0"

func _selectFirstItem() -> void:
	# Focus the first shop item and update details UI
	if shopItemsContainer.get_child_count() == 0:
		return

	var btn := shopItemsContainer.get_child(0) as ShopItemButton
	btn.grab_focus()
	_updateItemDetails(btn.itemData)
	lastFocusedButton = btn

func _updateItemDetails(item: ItemData) -> void:
	# Update item details UI elements based on the selected item
	if item == null:
		itemImage.texture = null
		itemNameLabel.text = ""
		itemCostLabel.text = ""
		itemDescriptionLabel.text = ""
		itemOwnedLabel.text = ""
		return

	itemImage.texture = item.texture
	itemNameLabel.text = item.name
	itemDescriptionLabel.text = item.description
	itemCostLabel.text = str(item.cost)
	itemOwnedLabel.text = str(get_item_quantity(item))

func _onShopItemPressed(btn: ShopItemButton) -> void:
	# Handle purchase attempt when an item button is pressed
	if btn == null or btn.itemData == null:
		return

	var item := btn.itemData
	var inventory = PlayerManager.get_inventory()
	if inventory == null:
		push_error("Inventory not found when attempting purchase")
		return

	if get_item_quantity(currencyItem) >= item.cost:
		play_purchase(item, inventory)
	else:
		emit_signal("purchaseFailed", item)
		_playAudio(preload("uid://cil5caxmhk6gq"))
		gemAnimationPlayer.play("not_enough_gems")
		gemAnimationPlayer.seek(0)

	lastFocusedButton = btn

func play_purchase(item: ItemData, inventory: InventoryData) -> void:
	# Perform purchase: play sound, add item, deduct cost, update UI and signals
	_playAudio(preload("uid://beka4wjw2je1u"))
	inventory.addItem(item)
	inventory.useItem(currencyItem, item.cost)
	_updateGems()
	_updateItemDetails(item)
	emit_signal("purchaseRequested", item)
	get_tree().paused = true

func _onShopItemFocused(btn: ShopItemButton) -> void:
	# Play audio and update details UI when an item is focused
	if btn == null or btn.itemData == null:
		return

	_playAudio(preload("uid://8ciyfewwer1y"))
	_updateItemDetails(btn.itemData)
	lastFocusedButton = btn

func _playAudio(stream: AudioStream) -> void:
	# Play a given audio stream on the audio player
	audioPlayer.stream = stream
	audioPlayer.play()

func _onAudioFinished() -> void:
	# Restore focus to the last focused button after audio finishes
	if lastFocusedButton and lastFocusedButton.is_inside_tree():
		lastFocusedButton.grab_focus()

func get_item_quantity(item: ItemData) -> int:
	# Helper to get quantity of a specific item from inventory
	return PlayerManager.INVENTORY_DATA.get_item_held_qty(item)
