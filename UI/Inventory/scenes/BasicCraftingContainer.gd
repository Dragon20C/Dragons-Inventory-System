extends Control

onready var slot_container = preload("res://UI/Inventory/scenes/BasicCraftingSlot.tscn")
var items = database.new()
var crafting_items : Array
var player_container
var held_item
func _ready():
	crafting_items = items.craftable_items
	player_container = Singleton.player_inventory
	held_item = Singleton.hand_slot.hand_slot
	set_up_basic_crafting()
	
func set_up_basic_crafting():
	for x in crafting_items:
		if x.can_craft == true:
			var instance = slot_container.instance()
			instance.requirements = x.ingredients
			instance.result = x
			instance.amount = x.result_amount
			$ScrollContainer/GridContainer.add_child(instance)
			instance.check_item_slot()
			instance.connect("gui_input",self,"slot_pressed",[instance])
	
func slot_pressed(event : InputEvent ,slot):
	if held_item.item == null:
		if event is InputEvent:
			if Input.is_action_pressed("left_click"):
					for x in slot.requirements.size():
						if check_has_item(slot.requirements[x][0]):
							if slot.requirements[x][1] <= check_item_amount(slot.requirements[x][0]):
								remove_items(slot)
								craft_item(slot)
							return
						return

func remove_items(slot):
	for x in slot.requirements.size():
		var left = slot.requirements[x][1]
		for i in Singleton.player_container.slots:
			if i.Item_slot.item == slot.requirements[x][0]:
				if i.Item_slot.amount <= slot.requirements[x][1] and left != 0:
					left -= i.Item_slot.amount
					i.Item_slot.set_slot(null,null)
				elif i.Item_slot.amount > slot.requirements[x][1] and left != 0:
					i.Item_slot.remove_amount(left)
					left = 0
			i.check_item_slot()
			
func craft_item(slot):
	held_item.set_slot(slot.result,slot.amount)
	Singleton.hand_slot.check_item_slot()
	
func find_empty_slot():
	for x in player_container.size():
		if player_container[x].Item_slot.item == null:
			return x
		
func check_has_item(_item):
	for x in Singleton.player_container.slots:
		if x.Item_slot.item == _item:
			return true
	return false

func check_item_amount(_item):
	var amount : int = 0
	for x in Singleton.player_container.slots:
		if x.Item_slot.item == _item:
			amount += x.Item_slot.amount
	return amount
