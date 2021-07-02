extends CanvasLayer

var inventory_shell = preload("res://Scenes/Container.tscn") # Does not have a inventory attached
onready var Held_Icon = get_node("Held_Item/Icon")
onready var held_Amount = get_node("Held_Item/Icon/Amount")
onready var inventory_location = get_node("CenterContainer/HBoxContainer")
var inventory_state : bool = false

var player_inventory : Array = [
	null,Item_Class.new(ItemData.item_dict["Cola"],5),null,null,null,
	null,Item_Class.new(ItemData.item_dict["Cola"],32),null,Item_Class.new(ItemData.item_dict["Apple"],100),null,
	Item_Class.new(ItemData.item_dict["Hammer"],5),null,null,Item_Class.new(ItemData.item_dict["Apple"],53),null,
	null,null,null,Item_Class.new(ItemData.item_dict["Sword"],5),null,
	null,null,Item_Class.new(ItemData.item_dict["Pick"],5),null,Item_Class.new(ItemData.item_dict["Apple"],100),
	null,Item_Class.new(ItemData.item_dict["Apple"],18),null,Item_Class.new(ItemData.item_dict["Spade"],5),null,
	null,null,null,null,null,
	null,
	]
var item = [null]
var current_inv
var previous_slot : int
var player : KinematicBody

func _ready():
	player = get_parent()
	SignalBus.connect("ui_opened",get_parent(),"ui_opened")
	SignalBus.connect("ui_closed",get_parent(),"ui_closed")
	get_node("Hot_Bar_Container/Hot_Bar").ready_hot_bar()
	
func _process(delta):
	if Input.is_action_just_pressed("Inventory"):
		inventory_state = !inventory_state
		if inventory_state:
			SignalBus.emit_signal("ui_opened")
			inventory_location.visible = true
			spawn_inventory(player_inventory)
		else:
			return_to_slot()
			SignalBus.emit_signal("ui_closed")
			inventory_location.get_child(0).queue_free()
			if inventory_location.get_child(1) != null:
				inventory_location.get_child(1).queue_free()
			inventory_location.visible = false
			
	if Input.is_action_just_pressed("right_click"): # checks the raycast for chests
		if player.raycast.is_colliding():
			var object = player.raycast.get_collider()
			if object.is_in_group("chest"):
				#object.get_parent().animation.play("Opening") # this needs to be better
				open_inventory_with_chest(object.get_parent().inventory)
				
func open_inventory_with_chest(chest):
	inventory_state = true
	inventory_location.visible = true
	SignalBus.emit_signal("ui_opened")
	spawn_inventory(player_inventory)
	spawn_inventory(chest)
	
func update_held_item():
	if item[0] != null:
		Held_Icon.texture = item[0].icon
		held_Amount.text = str(item[0].amount)
	else:
		Held_Icon.texture = null
		held_Amount.text = ""
		
func return_to_slot(): # If the held item array has an item and inventory is closed return it to the slot
	if item[0] != null:
		current_inv.inventory[previous_slot] = item[0]
		item[0] = null
		current_inv.update_slot(current_inv.inventory,previous_slot)
		update_held_item()
		
func spawn_inventory(Inventory):
	var instance = inventory_shell.instance()
	instance.set_inventory(Inventory)
	inventory_location.add_child(instance)
