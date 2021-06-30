extends NinePatchRect

var inventory : Array = [null,null,null,null,null,null]
var inventory_manager
var slots: Array
var HboxContainer

var droppable : bool = false
var droppable_index : int

func _ready():
	slots = get_node("GridContainer").get_children()
	inventory_manager = get_parent().get_parent()
	HboxContainer = get_parent().get_parent().get_child(0).get_child(0) # not sure if this is a good idea
func ready_hot_bar():
	for i in slots.size():
		slots[i].get_node("Button").connect("pressed",self,"slot_pressed",[i])
		slots[i].get_node("Button").connect("mouse_entered",self,"mouse_focus",[i])
		slots[i].get_node("Button").connect("mouse_exited",self,"mouse_unfocus")
		update_slot(inventory,i)

func mouse_focus(index):
	droppable = true
	droppable_index = index
	
func mouse_unfocus():
	droppable = false
	
func _process(delta):
	if Input.is_action_just_pressed("right_click") and droppable and HboxContainer.visible == true: # If mouse is on a button
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
	
func slot_pressed(index):
	if HboxContainer.visible == true:
		if inventory_manager.item[0] == null and inventory[index] != null: # Picks up the item
			pick_item(inventory,index)
			
		elif inventory_manager.item[0] != null and inventory[index] == null: # Drops the item
			drop_item(inventory,index)

		elif inventory_manager.item[0] != null and inventory[index] != null: # Swaps the item
			if inventory_manager.item[0].name == inventory[index].name: # Checks if they are the same then combine
				combine_item(inventory,index)
					
			else: # Actually swaps the item
				swap_item(inventory,index)
				
func update_slot(cur_inv,index): # Updates a specific slot also saves some memory no need to look at the array each time
	if cur_inv[index] == null:
		slots[index].amount.text = ""
		slots[index].icon.texture = null
	else:
		slots[index].amount.text = str(cur_inv[index].amount)
		slots[index].icon.texture = cur_inv[index].icon
	inventory_manager.update_held_item()

