extends NinePatchRect


var inventory : Array
var slots_array : Array = []
onready var grid_container = get_node("GridContainer")
var inventory_manager

var droppable : bool = false
var droppable_index : int

func set_inventory(selected_inventory):
	inventory = selected_inventory
	

func _ready():
	inventory_manager = get_parent().get_parent().get_parent()
	Setup_Inventory()

func _process(delta):
	if Input.is_action_just_pressed("right_click") and droppable: # If mouse is on a button
		if inventory_manager.item[0] != null and inventory_manager.item[0].amount == 1 and inventory[droppable_index] != null and inventory[droppable_index].name == inventory_manager.item[0].name: # if one item is left add and delete held item
			inventory[droppable_index].amount += 1
			inventory_manager.item[0] = null
			update_slot(inventory,droppable_index)
		
		elif inventory_manager.item[0] == null and inventory[droppable_index] != null and inventory[droppable_index].amount > 1: # pick up half a stack
			if (inventory[droppable_index].amount % 2) == 0:
				inventory_manager.item[0] = Item_Data.new(ItemData.item_dict[inventory[droppable_index].name],inventory[droppable_index].amount / 2)
				inventory[droppable_index].amount = (inventory[droppable_index].amount / 2)
			else:
				inventory_manager.item[0] = Item_Data.new(ItemData.item_dict[inventory[droppable_index].name],inventory[droppable_index].amount / 2) # This will cause issues when halfing odd numbers
				inventory[droppable_index].amount = (inventory[droppable_index].amount / 2) + 1
			update_slot(inventory,droppable_index)
			
		elif inventory_manager.item[0] != null and inventory[droppable_index] != null and inventory_manager.item[0].name == inventory[droppable_index].name: # If input and slot isnt empty add and remove 1
			if inventory[droppable_index].amount < inventory[droppable_index].max_amount: # If there is space
				if inventory_manager.item[0].amount > 1:
					inventory[droppable_index].amount += 1
					inventory_manager.item[0].amount -= 1
					update_slot(inventory,droppable_index)
						# this could be combined with the first if statement but for now just leaving it
		else:
			if inventory_manager.item[0] != null and inventory_manager.item[0].amount > 1 and inventory[droppable_index] == null: # If the slot is empty create one
				inventory[droppable_index] = Item_Data.new(ItemData.item_dict[inventory_manager.item[0].name],1) # Setting the new inventory slot to new item
				inventory_manager.item[0].amount -= 1 # Removes one to make it look like its dropping a item
				update_slot(inventory,droppable_index)

func Setup_Inventory(): # makes the inventory and buttons ready while also linking it to an array
	slots_array = grid_container.get_children()
	for i in slots_array.size():
		slots_array[i].get_node("Button").connect("pressed",self,"slot_pressed",[i]) # Giving each button an index
		slots_array[i].get_node("Button").connect("mouse_entered",self,"mouse_focus",[i])
		slots_array[i].get_node("Button").connect("mouse_exited",self,"mouse_unfocus")
		update_slot(inventory,i) # updates the slots with the inventory array

func update_slot(cur_inv,index): # Updates a specific slot also saves some memory no need to look at the array each time
	if cur_inv[index] == null:
		slots_array[index].amount.text = ""
		slots_array[index].icon.texture = null
	else:
		slots_array[index].amount.text = str(cur_inv[index].amount)
		slots_array[index].icon.texture = cur_inv[index].icon
	inventory_manager.update_held_item()
	
func mouse_focus(index): # Adding a tool tip ui when the mouse is focused on a item
	droppable = true
	droppable_index = index
	if inventory[index] != null:
		pass
		#tool_tip.visible = true
		#tool_tip.tool_name.text = "name : " + inventory[index].name

func mouse_unfocus(): # Makes it unvisible so we cant see it if it isnt on a button
	droppable = false
	#tool_tip.visible = false

func pick_item(cur_inv,index):
	inventory_manager.current_inv = self
	inventory_manager.previous_slot = index
	inventory_manager.item[0] = cur_inv[index]
	cur_inv[index] = null
	update_slot(inventory,index)

func drop_item(cur_inv,index):
	cur_inv[index] = inventory_manager.item[0]
	inventory_manager.item[0] = null
	update_slot(inventory,index)

func combine_item(cur_inv,index):
	var check_max = cur_inv[index].amount + inventory_manager.item[0].amount
	if check_max > cur_inv[index].max_amount: # Checks if max amount has reached
		var left_amount = check_max - cur_inv[index].max_amount # Take whats left
		cur_inv[index].amount = cur_inv[index].max_amount
		inventory_manager.item[0].amount = left_amount
		update_slot(inventory,index)

	elif check_max <= cur_inv[index].max_amount: # checks if its the same or less
		cur_inv[index].amount += inventory_manager.item[0].amount
		inventory_manager.item[0] = null
		update_slot(inventory,index)

func swap_item(cur_inv,index):
	var saved = cur_inv[index]
	cur_inv[index] = inventory_manager.item[0]
	inventory_manager.item[0] = saved
	update_slot(inventory,index)

func stack_items(cur_inv,index):
	inventory_manager.item[0] = cur_inv[index]
	cur_inv[index] = null
	update_slot(inventory,index)
	
	for x in cur_inv.size():
		if cur_inv[x] != null:
			if cur_inv[x].name == inventory_manager.item[0].name:
				var check_max = cur_inv[x].amount + inventory_manager.item[0].amount
				if check_max > inventory_manager.item[0].max_amount: # Checks if max amount has reached
					var left_amount = check_max - cur_inv[x].max_amount # Take whats left
					cur_inv[x].amount = left_amount
					inventory_manager.item[0].amount = inventory_manager.item[0].max_amount
					update_slot(inventory,x)
					inventory_manager.update_held_item()
					
				elif check_max <= cur_inv[x].max_amount: # checks if its the same or less
					inventory_manager.item[0].amount += cur_inv[x].amount
					cur_inv[x] = null
					update_slot(inventory,x)
					inventory_manager.update_held_item()
					
	
func slot_pressed(index): # Detects button presses with an index
	if Input.is_key_pressed(KEY_SHIFT) and inventory_manager.item[0] == null and inventory[index] != null:
		stack_items(inventory,index)

		
	elif inventory_manager.item[0] == null and inventory[index] != null: # Picks up the item
		pick_item(inventory,index)
		
	elif inventory_manager.item[0] != null and inventory[index] == null: # Drops the item
		drop_item(inventory,index)

	elif inventory_manager.item[0] != null and inventory[index] != null: # Swaps the item
		if inventory_manager.item[0].name == inventory[index].name: # Checks if they are the same then combine
			combine_item(inventory,index)
				
		else: # Actually swaps the item
			swap_item(inventory,index)


