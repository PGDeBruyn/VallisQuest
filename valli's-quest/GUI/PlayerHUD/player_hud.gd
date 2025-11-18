extends CanvasLayer

var hearts: Array[HeartGUI] = []
var maxHearts: int = 0

func _ready() -> void:
	_collect_hearts()
	_hide_all_hearts()

func _collect_hearts() -> void:
	for node in $Control/GridContainer.get_children():
		if node is HeartGUI:
			hearts.append(node)

func _hide_all_hearts() -> void:
	for heart in hearts:
		heart.visible = false

func adjustHP(current_hp: int, max_hp: int) -> void:
	maxHearts = int(ceil(max_hp / 2.0))
	_show_relevant_hearts()
	_apply_hp_to_hearts(current_hp)

func _show_relevant_hearts() -> void:
	for i in range(maxHearts):
		hearts[i].visible = true
	for i in range(maxHearts, hearts.size()):
		hearts[i].visible = false

func _apply_hp_to_hearts(current_hp: int) -> void:
	var remaining_hp = current_hp
	for heart in hearts:
		if not heart.visible:
			continue
		var heart_value = 0
		if remaining_hp >= 2:
			heart_value = 2
			remaining_hp -= 2
		elif remaining_hp == 1:
			heart_value = 1
			remaining_hp -= 1
		heart.set_value(heart_value)  # <-- here
