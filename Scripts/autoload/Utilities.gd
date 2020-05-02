extends Node


func chance(num):
	randomize()
	
	if randi() % 100 <= num:
		return true
	else:
		return false
		
func choose(choices):
	randomize()
	var rand_index = randi() % choices.size()
	return choices[rand_index]

func create_tree_range(obj_tree, root, property_name, value, minimum, maximum, increment, enabled=true):
	var property = obj_tree.create_item(root)
	property.set_cell_mode(1,TreeItem.CELL_MODE_RANGE)
	property.set_text(0,property_name)
	property.set_range_config(1, minimum, maximum, increment)
	property.set_range(1,value)
	property.set_editable(1,enabled)
	return property

func create_tree_bool(obj_tree, root, property_name, checked, enabled=true):
	var property = obj_tree.create_item(root)
	property.set_cell_mode(1,TreeItem.CELL_MODE_CHECK)
	property.set_text(0,property_name)
	property.set_checked(1,checked)
	property.set_editable(1,enabled)
	return property

func add_click_sounds(path):
	for node in path.get_children():
		if (node.get_class() == "Button"):
			node.connect("pressed", self, "buttonSound")
		add_click_sounds(node)
