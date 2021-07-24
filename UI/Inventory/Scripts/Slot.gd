extends Control

onready var icon = get_node("slot")
onready var amount = get_node("amount")

var Item_slot = item_slot.new()
var index : int

func check_item_slot():
	if Item_slot.item != null:
		icon.texture = Item_slot.item.image
		amount.text = str(Item_slot.amount)
	else:
		icon.texture = null
		amount.text = ""
		
