extends Control


onready var slots = get_node("EquipmentArea/EquipmentSlots").get_children()
var equip_types = ["head","face","chest","belt","legs","feet"]
var held_item : Node2D
var container 
# Called when the node enters the scene tree for the first time.
func _ready():
	container = Singleton.player_equipment_container
	Singleton.player_equipment = self
	held_item = Singleton.hand_slot
	set_up_slots()
	
func set_up_slots():
	for x in slots.size():
		slots[x].connect("gui_input",self,"slot_pressed",[slots[x]])
		slots[x].equipment_type = equip_types[x]
		if container[x] != []:
			slots[x].Item_slot.set_slot(container[x][0],container[x][1])
			if slots[x].Item_slot.amount > slots[x].Item_slot.item.max_stack:
				slots[x].Item_slot.amount = slots[x].Item_slot.item.max_stack
		slots[x].check_item_slot() # updates each slot
		
func slot_pressed(event : InputEvent, slot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if held_item.hand_slot.item != null and held_item.hand_slot.item.type == Item_Object.item_type.Equipment:
				if held_item.hand_slot.item.armor_type == slot.equipment_type:
					drop_item(slot)
			elif slot.Item_slot.item != null and held_item.hand_slot.item == null:
				pick_up(slot)
				
func drop_item(slot):
	slot.Item_slot.set_slot(held_item.hand_slot.item,held_item.hand_slot.amount)
	held_item.hand_slot.set_slot(null,null)
	slot.check_item_slot()
	held_item.check_item_slot()
	
func pick_up(slot):
	held_item.hand_slot.set_slot(slot.Item_slot.item,slot.Item_slot.amount)
	slot.Item_slot.set_slot(null,null)
	slot.check_item_slot()
	held_item.check_item_slot()

func save():
	Singleton.player_equipment_container.clear()
	for x in slots:
		if x.Item_slot.item != null:
			Singleton.player_equipment_container.append([x.Item_slot.item,x.Item_slot.amount])
		else:
			Singleton.player_equipment_container.append([])
