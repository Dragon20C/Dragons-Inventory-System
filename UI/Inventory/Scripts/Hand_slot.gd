extends Node2D

onready var icon = get_node("Slot")
onready var amount = get_node("Amount")

var hand_slot = item_slot.new()

func _ready():
	Singleton.hand_slot = self
	check_item_slot()

func _process(delta):
	position = get_global_mouse_position()

func check_item_slot():
	if hand_slot.item != null:
		icon.texture = hand_slot.item.image
		amount.text = str(hand_slot.amount)
	else:
		icon.texture = null
		amount.text = ""
		

