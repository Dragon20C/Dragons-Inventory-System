extends Control

var previous_slot
var hand_slot
var container : Array
onready var slots = get_node("Grid").get_children()

func _ready():
	container = Singleton.player_inventory.inventory
	Singleton.player_container = self
	hand_slot = Singleton.hand_slot.hand_slot
	inventory_setup()
	
func inventory_setup():
	for x in slots.size():
		slots[x].connect("gui_input",self,"slot_pressed",[slots[x]]) # sets up slots
		slots[x].index = x
		if container[x] != []:
			slots[x].Item_slot.set_slot(container[x][0],container[x][1])
			if slots[x].Item_slot.amount > slots[x].Item_slot.item.max_stack:
				slots[x].Item_slot.amount = slots[x].Item_slot.item.max_stack
		slots[x].check_item_slot()

func slot_pressed(event : InputEvent ,slot):
	if event is InputEvent and Input.is_action_pressed("shift"):
		if Input.is_action_pressed("left_click") and hand_slot.item == null and slot.Item_slot.item != null:
				stack_items(slot)
		
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			previous_slot = slot
			if hand_slot.item == null and slot.Item_slot.item != null:
				pick_up(slot)
				
			elif hand_slot.item != null and slot.Item_slot.item == null:
				drop_item(slot)
				
			elif hand_slot.item != null and slot.Item_slot.item != null:
				if hand_slot.item.id != slot.Item_slot.item.id:
					swap_items(slot)
					
				else:
					combine_items(slot)
					
		elif event.button_index == BUTTON_RIGHT && event.pressed:
			if hand_slot.item == null and slot.Item_slot.item != null:
				if slot.Item_slot.amount > 1:
					half_pick_up(slot)
				
			elif hand_slot.item != null and slot.Item_slot.item != null:
				if hand_slot.item.id == slot.Item_slot.item.id:
					if hand_slot.amount > 1:
						add_amount_to_slot(slot)
						
			elif hand_slot.item != null and slot.Item_slot.item == null:
				if hand_slot.amount > 1:
					add_to_empty_slot(slot)
			previous_slot = slot
			
func pick_up(slot):
	hand_slot.set_slot(slot.Item_slot.item,slot.Item_slot.amount)
	slot.Item_slot.set_slot(null,null)
	slot.check_item_slot()
	Singleton.hand_slot.check_item_slot()
	
func drop_item(slot):
	slot.Item_slot.set_slot(hand_slot.item,hand_slot.amount)
	hand_slot.set_slot(null,null)
	slot.check_item_slot()
	Singleton.hand_slot.check_item_slot()

func swap_items(slot):
	var storage : Array = [slot.Item_slot.item,slot.Item_slot.amount]
	slot.Item_slot.set_slot(hand_slot.item,hand_slot.amount)
	hand_slot.set_slot(storage[0],storage[1])
	slot.check_item_slot()
	Singleton.hand_slot.check_item_slot()

func combine_items(slot):
	var max_amount : int = slot.Item_slot.amount + hand_slot.amount
	if max_amount <= slot.Item_slot.item.max_stack:
		slot.Item_slot.amount += hand_slot.amount
		hand_slot.set_slot(null,null)
	slot.check_item_slot()
	Singleton.hand_slot.check_item_slot()

func half_pick_up(slot):
	if slot.Item_slot.amount % 2 == 0:
		hand_slot.set_slot(slot.Item_slot.item,slot.Item_slot.amount / 2)
		slot.Item_slot.set_slot(slot.Item_slot.item,slot.Item_slot.amount / 2)
	else:
		hand_slot.set_slot(slot.Item_slot.item,(slot.Item_slot.amount / 2) + 1)
		slot.Item_slot.set_slot(slot.Item_slot.item,slot.Item_slot.amount / 2)
	slot.check_item_slot()
	Singleton.hand_slot.check_item_slot()

func add_amount_to_slot(slot):
	if slot.Item_slot.amount < slot.Item_slot.item.max_stack:
		slot.Item_slot.amount += 1
		hand_slot.amount -= 1
		slot.check_item_slot()
		Singleton.hand_slot.check_item_slot()

func add_to_empty_slot(slot):
	if slot.Item_slot.item == null:
		slot.Item_slot.set_slot(hand_slot.item,1)
		hand_slot.amount -= 1
	elif hand_slot.amount < hand_slot.item.max_stack:
		slot.Item_slot.amount -= 1
		hand_slot.amount += 1
	slot.check_item_slot()
	Singleton.hand_slot.check_item_slot()

func stack_items(slot):
	pick_up(slot)
	for x in slots:
		if x.Item_slot.item != null:
			if x.Item_slot.item.id == hand_slot.item.id:
				var picked_amount = x.Item_slot.amount + hand_slot.amount
				if picked_amount > hand_slot.item.max_stack:
					var left_amount = picked_amount - x.Item_slot.item.max_stack # Take whats left
					x.Item_slot.amount = left_amount
					hand_slot.amount = hand_slot.item.max_stack
					x.check_item_slot()
					Singleton.hand_slot.check_item_slot()
					
				elif picked_amount <= hand_slot.item.max_stack: # checks if its the same or less
					hand_slot.add_amount(x.Item_slot.amount)
					x.Item_slot.set_slot(null,null)
					x.check_item_slot()
					Singleton.hand_slot.check_item_slot()

func add_item(_item : Resource,_amount : int):
	var has_item : bool = false
	for x in slots.size():
		if slots[x].Item_slot.item == _item:
			slots[x].Item_slot.add_amount(_amount)
			has_item = true
			return
	if !has_item:
		container.append(item_slot.new().set_slot(_item,_amount))
		#var empty_slot = find_empty_slot()
		#container[empty_slot].set_slot(_item,_amount) # maybe should be append

func save():
	Singleton.player_inventory.clear()
	return_to_slot()
	for x in slots:
		if x.Item_slot.item != null:
			Singleton.player_inventory.append([x.Item_slot.item,x.Item_slot.amount])
		else:
			Singleton.player_inventory.append([])
	

func return_to_slot():
	if hand_slot.item != null:
		if previous_slot.Item_slot.item != null:
			previous_slot.Item_slot.amount += hand_slot.amount
			hand_slot.set_slot(null,null)
		else:
			previous_slot.Item_slot.set_slot(hand_slot.item,hand_slot.amount)
			hand_slot.set_slot(null,null)
		previous_slot.check_item_slot()
		Singleton.hand_slot.check_item_slot()
		
func find_empty_slot():
	for x in container.size():
		if container[x].item == null:
			return x
		
func check_has_item(_item):
	for x in container:
		if x.item == _item:
			return true
	return false

func check_item_amount(_item):
	var amount : int = 0
	for x in container:
		if x.item == _item:
			amount += x.amount
	return amount
