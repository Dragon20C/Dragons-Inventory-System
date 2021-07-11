extends NinePatchRect


var crafting_scene = preload("res://Scenes/Crafting_Slot.tscn")
var recipes = Item_Recipes.new()
var inventory
var inventory_manager
var player_container
onready var crafting_location = get_node("ScrollContainer/VBoxContainer")


var items_available = {} # Adds all the items into a dictionary that can see how much is left
#onready var crafting_slot = preload("res://Scenes/Crafting_Slot.tscn")

func _ready():
	set_up_crafting()
	check_items_avilable()
	create_crafting_list()
	
func update_slot(cur_inv,index): # Updates a specific slot also saves some memory no need to look at the array each time
	if cur_inv[index] == null:
		player_container.slots_array[index].amount.text = ""
		player_container.slots_array[index].icon.texture = null
	else:
		player_container.slots_array[index].amount.text = str(cur_inv[index].amount)
		player_container.slots_array[index].icon.texture = cur_inv[index].icon
	inventory_manager.update_held_item()
	
func set_up_crafting():
	self.inventory = get_parent().get_parent().get_parent().player_inventory
	inventory_manager = get_parent().get_parent().get_parent()
	player_container = get_parent().get_child(0)
func create_crafting_list():
	for x in recipes.Item_array.size():
		var instance = crafting_scene.instance()
		crafting_location.add_child(instance)
		instance.item_name.text = recipes.Item_array[x].result.name
		instance.item_icon.texture = recipes.Item_array[x].result.icon
		instance.button.connect("pressed",self,"craft_button_pressed",[x])
		for y in recipes.Item_array[x].materials.size():
			if y == 0:
				instance.material_1.texture = recipes.Item_array[x].materials[y].icon
				instance.amount_1.text = str(recipes.Item_array[x].materials[y].amount)
			elif y == 1:
				instance.material_2.texture = recipes.Item_array[x].materials[y].icon
				instance.amount_2.text = str(recipes.Item_array[x].materials[y].amount)
			elif y == 2:
				instance.material_3.texture = recipes.Item_array[x].materials[y].icon
				instance.amount_3.text = str(recipes.Item_array[x].materials[y].amount)
			
func check_items_avilable(): # Puts all the items into a dict with the amounts together
	items_available.clear()
	for x in inventory:
		if x != null:
			if x.name in items_available:
				items_available[x.name] += x.amount
			else:
				items_available[x.name] = x.amount
	
func can_craft(index):
	var craftable = true
	if inventory_manager.item[0] != null:
		craftable = false
		return craftable
	check_items_avilable() # everytime the player crafts an item check items avilable
	for material in recipes.Item_array[index].materials: #item.recipie:
		if items_available.has(material.name):
			if items_available[material.name] < material.amount:
				craftable = false
		else:
			craftable = false
			
	return craftable
	
func remove_items(index):
	for material in recipes.Item_array[index].materials: #item.recipie:
		var amount_left = material.amount
		for x in inventory.size():
			if inventory[x] != null and inventory[x].name == material.name:
				if inventory[x].amount < material.amount and amount_left != 0:
					amount_left -= inventory[x].amount
					inventory[x] = null
					player_container.update_slot(inventory,x)
				elif inventory[x].amount > material.amount and amount_left != 0:
					inventory[x].amount -= amount_left
					amount_left = 0
					player_container.update_slot(inventory,x)
				elif inventory[x].amount == material.amount and amount_left != 0:
					inventory[x] = null
					amount_left = 0
					player_container.update_slot(inventory,x)

func find_empty_slot():
	for x in inventory.size():
		if inventory[x] == null:
			return x

func craft_item(index):
	inventory_manager.current_inv = self
	inventory_manager.previous_slot = find_empty_slot()
	inventory_manager.item[0] = Item_Class.new(ItemData.item_dict[recipes.Item_array[index].result.name],recipes.Item_array[index].result.amount) 
	inventory_manager.update_held_item()
	print("crafted an item")

func craft_button_pressed(index):

	if can_craft(index):
		remove_items(index)
		craft_item(index)
	else:
		print("cant craft")
