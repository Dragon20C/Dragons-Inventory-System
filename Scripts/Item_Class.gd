class_name Item_Class

var amount : int
var max_amount : int
var name : String
var data_type : String
var icon : Texture

func _init(Item : BaseItem , amount : int):
	self.amount = amount
	max_amount = Item.max_amount
	name = Item.name
	data_type = Item.data_type
	icon = Item.icon
	if amount > max_amount:
		self.amount = max_amount
