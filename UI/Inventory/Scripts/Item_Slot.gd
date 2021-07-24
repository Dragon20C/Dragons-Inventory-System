extends Node
class_name item_slot

export(Resource) var item
export(int) var amount
	
func set_slot(_item,_amount):
	item = _item
	amount = _amount
	
func add_amount(_value):
	amount += _value
	
func remove_amount(_value):
	amount -= _value
