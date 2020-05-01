extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func check_all_near(map, centerTile, checkFor):
	var found = []
	
	var neighbors = [Vector2(-1,1),Vector2(0,1),Vector2(1,1),
					Vector2(-1,0),Vector2(1,0),Vector2(-1,-1),
					Vector2(0,-1),Vector2(1,-1),Vector2(0,0)]
					
	for vectorNear in neighbors:
		var currentTile = centerTile + vectorNear
		if map.get_cellv(currentTile) == checkFor:
			found.append(currentTile)
	return found

func _on_Timer_timeout():
	Globals.TicksElapsed += 1
	var treeArray = Globals.BlockChecks.TreeLeaves
	if treeArray.size() > 0:
		for tree in treeArray:
			var checkForLeaves = check_all_near(Globals.S2, tree, 6)
			if checkForLeaves.size() > 0:
				var tileToRemove = checkForLeaves[rand_range(0,checkForLeaves.size())]
				if check_all_near(Globals.S0, tileToRemove, 5).size() < 1:
					Globals.S2.set_cellv(tileToRemove,-1)
			else:
				Globals.BlockChecks.TreeLeaves.erase(tree)
