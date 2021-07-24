extends Resource
class_name Item_Object

enum item_type {Food,Equipment,Weapon,Misc}

export (int) var id
export (String) var name
export (Texture) var image
export (item_type) var type
export (int) var max_stack
export (String,MULTILINE)var description
export (bool) var can_craft = false
export (int) var result_amount
export (Array) var ingredients 
