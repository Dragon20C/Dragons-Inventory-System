class_name Item_Recipes

var pick = Recipes.new([Item_Class.new(ItemData.item_dict["Wood"],3),Item_Class.new(ItemData.item_dict["Rock"],3),Item_Class.new(ItemData.item_dict["Rope"],2)],Item_Class.new(ItemData.item_dict["Pick"],1))
var spade = Recipes.new([Item_Class.new(ItemData.item_dict["Wood"],3),Item_Class.new(ItemData.item_dict["Rock"],1)],Item_Class.new(ItemData.item_dict["Spade"],1))
var hammer = Recipes.new([Item_Class.new(ItemData.item_dict["Wood"],3),Item_Class.new(ItemData.item_dict["Rock"],6),Item_Class.new(ItemData.item_dict["Rope"],3)],Item_Class.new(ItemData.item_dict["Hammer"],1))
var axe = Recipes.new([Item_Class.new(ItemData.item_dict["Wood"],2),Item_Class.new(ItemData.item_dict["Rock"],3),Item_Class.new(ItemData.item_dict["Rope"],2)],Item_Class.new(ItemData.item_dict["Axe"],1))
var sword = Recipes.new([Item_Class.new(ItemData.item_dict["Wood"],1),Item_Class.new(ItemData.item_dict["Rock"],2),Item_Class.new(ItemData.item_dict["Rope"],1)],Item_Class.new(ItemData.item_dict["Sword"],1))

var Item_array = [pick,spade,hammer,axe,sword]
