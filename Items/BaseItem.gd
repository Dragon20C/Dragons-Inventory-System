extends Resource
class_name BaseItem

export (String) var name
export (Texture) var icon
export var max_amount : int = 1
export(String,"tool","food","armor","material","misc") var data_type = "misc"
