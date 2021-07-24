extends CenterContainer


onready var Icon = get_node("Panel/Icon")

var Item_slot = item_slot.new()
var equipment_type : String

func check_item_slot():
	if Item_slot.item != null:
		Icon.texture = Item_slot.item.image
	else:
		Icon.texture = null
