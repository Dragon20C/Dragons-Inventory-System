extends Control

onready var Icon = get_node("slot")
onready var Amount = get_node("amount")

var requirements : Array = [] 
var result : Resource
var amount : int

func check_item_slot():
	Icon.texture = result.image
	Amount.text = str(amount)
		
