extends Item_Object
class_name Equipment

export (int) var defence = 0
export (int) var magic_defence = 0
export (int) var waight = 0
export(String, "head","face","chest","belt","legs","feet") var armor_type

func _init():
	type = item_type.Equipment
