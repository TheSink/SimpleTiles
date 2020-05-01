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
