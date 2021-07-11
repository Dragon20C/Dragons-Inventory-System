extends Resource
class_name Item_Resource

export (String) var name
export (Texture) var icon
export var max_amount : int = 1
export(String,"tool","food","armor","misc") var data_type = "misc"

export(bool) var is_craftable = false
export(Array) var craft_items = [null]
export(Array,int) var craft_amount = [null]
