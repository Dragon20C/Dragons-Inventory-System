extends CanvasLayer

var item = database.new()
onready var inventory_base = preload("res://Scenes/Player_Container.tscn")
var inventory_state : bool = false
var inventory : Array = [
	[],[],[item.chocolate,50],[],[],[],[],[],[],[],
	[],[],[item.diamond,99],[item.diamond_sword,5],[],[],[],[item.chocolate,30],[],[],
	[],[],[],[],[item.coco_beans,8],[],[],[],[],[],
	[],[]]
	
var equipment_container : Array = [[],[],[],[],[],[]] 

func _init(): # Need to set this up first before anything else
	Singleton.player_inventory = self
	Singleton.player_equipment_container = equipment_container
func _ready():
	Singleton.connect("ui_open",get_parent(),"ui_opened")
	Singleton.connect("ui_close",get_parent(),"ui_closed")

func _process(delta):
	if Input.is_action_just_pressed("Inventory_button"):
		inventory_state = !inventory_state
		if inventory_state:
			Singleton.emit_signal("ui_open")
			instance_inventory()
		else:
			Singleton.emit_signal("ui_close")
			if get_child(1).name == "Player_Container":
				get_child(1).queue_free()

func instance_inventory():
	var instance = inventory_base.instance()
	add_child(instance)
