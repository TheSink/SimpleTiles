extends Node

var mapData = {
	"surface": [],
	"above": [],
	"under": []
}

func CalculateBounds(map):
	var min_x = 0
	var max_x = 0
	var min_y = 0
	var max_y = 0
	var used_cells = map.get_used_cells()
	for pos in used_cells:
		if pos.x < min_x:
			min_x = int(pos.x)
		elif pos.x > max_x:
			max_x = int(pos.x)
		if pos.y < min_y:
			min_y = int(pos.y)
		elif pos.y > max_y:
			max_y = int(pos.y)
	return Vector2(max_x-min_x, max_y-min_y)

func GenerateTable(map, bounds):
	for x in bounds:
		for y in bounds:
			var cell = map.get_cell(x,y)
			if cell != -1:
				mapData.surface.push_back([Vector2(x,y),cell])

func GetSaves():
	var files = []
	var dir = Directory.new()
	if not dir.dir_exists("user://saves/"):
		dir.open("user://")
		dir.make_dir("saves")
	dir.open("user://saves/")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not "." in file_name:
			files.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

	return files

func Save(SaveFileName="map"):
	print("[SAVE] Starting save.")
	var S0 = Globals.S0
	var S1 = Globals.S1
	var S2 = Globals.S2
	var U0 = Globals.U0
	var U1 = Globals.U1
	var U2 = Globals.U2
	var Exists = true
	
	var dir = Directory.new()
	if not dir.dir_exists("user://saves/"+SaveFileName):
		print("[SAVE] Directory not found for map, creating.")
		dir.open("user://saves/")
		dir.make_dir(SaveFileName)
		Exists = false
	dir.list_dir_end()
	
	Globals.UIMsg = "Saving map (1/8): S0"
	yield(get_tree().create_timer(0.01), "timeout")
	print("[SAVE] Saving S0 map.")
	var save_file = File.new()
	var dividedLines = 0
	var increment = 0
	save_file.open("user://saves/"+SaveFileName+"/S0.dat", File.WRITE)
	var smcells = S0.get_used_cells()
	for cell in smcells:
		if int(increment/1024) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			Globals.UIPercentage = (float(increment) / float(smcells.size()))*100
			dividedLines = int(increment/1024)
		increment += 1
		save_file.store_double(cell.x)
		save_file.store_double(cell.y)
		save_file.store_8(S0.get_cell(cell.x,cell.y))
	save_file.close()
	print("[SAVE] Saved, S0 map has " + str(increment) + " tiles.")
	
	Globals.UIMsg = "Saving map (2/8): S1"
	yield(get_tree().create_timer(0.01), "timeout")
	print("[SAVE] Saving S1 map.")
	save_file = File.new()
	dividedLines = 0
	increment = 0
	save_file.open("user://saves/"+SaveFileName+"/S1.dat", File.WRITE)
	var s1cells = S1.get_used_cells()
	for cell in s1cells:
		if int(increment/1024) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			print(str(cell.x) + " " + str(cell.y))
			Globals.UIPercentage = (float(increment) / float(s1cells.size()))*100
			dividedLines = int(increment/1024)
		increment += 1
		save_file.store_double(cell.x)
		save_file.store_double(cell.y)
		save_file.store_8(S1.get_cell(cell.x,cell.y))
	save_file.close()
	print("[SAVE] Saved, S1 map has " + str(increment) + " tiles.")
	
	Globals.UIMsg = "Saving map (3/8): S2"
	yield(get_tree().create_timer(0.01), "timeout")
	print("[SAVE] Saving S2 map.")
	save_file = File.new()
	dividedLines = 0
	increment = 0
	save_file.open("user://saves/"+SaveFileName+"/S2.dat", File.WRITE)
	var s2cells = S2.get_used_cells()
	for cell in s2cells:
		if int(increment/1024) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			print(str(cell.x) + " " + str(cell.y))
			Globals.UIPercentage = (float(increment) / float(s2cells.size()))*100
			dividedLines = int(increment/1024)
		increment += 1
		save_file.store_double(cell.x)
		save_file.store_double(cell.y)
		save_file.store_8(S2.get_cell(cell.x,cell.y))
	save_file.close()
	print("[SAVE] Saved, S2 map has " + str(increment) + " tiles.")
	
	Globals.UIMsg = "Saving map (4/8): U0"
	yield(get_tree().create_timer(0.01), "timeout")
	print("[SAVE] Saving U0 map.")
	save_file = File.new()
	dividedLines = 0
	increment = 0
	save_file.open("user://saves/"+SaveFileName+"/U0.dat", File.WRITE)
	var u0cells = U0.get_used_cells()
	for cell in u0cells:
		if int(increment/1024) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			Globals.UIPercentage = (float(increment) / float(u0cells.size()))*100
			dividedLines = int(increment/1024)
		increment += 1
		save_file.store_double(cell.x)
		save_file.store_double(cell.y)
		save_file.store_8(U0.get_cell(cell.x,cell.y))
	save_file.close()
	Globals.UIPercentage = -1
	print("[SAVE] Saved, U0 map has " + str(increment) + " tiles.")
	Globals.UIMsg = "Saving map (5/8): U1"
	yield(get_tree().create_timer(0.01), "timeout")
	print("[SAVE] Saving U1 map.")
	save_file = File.new()
	dividedLines = 0
	increment = 0
	save_file.open("user://saves/"+SaveFileName+"/U1.dat", File.WRITE)
	var u1cells = U1.get_used_cells()
	for cell in u1cells:
		if int(increment/1024) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			Globals.UIPercentage = (float(increment) / float(u1cells.size()))*100
			dividedLines = int(increment/1024)
		increment += 1
		save_file.store_double(cell.x)
		save_file.store_double(cell.y)
		save_file.store_8(U1.get_cell(cell.x,cell.y))
	save_file.close()
	Globals.UIPercentage = -1
	print("[SAVE] Saved, U1 map has " + str(increment) + " tiles.")
	Globals.UIMsg = "Saving map (6/8): U2"
	yield(get_tree().create_timer(0.01), "timeout")
	print("[SAVE] Saving U2 map.")
	save_file = File.new()
	dividedLines = 0
	increment = 0
	save_file.open("user://saves/"+SaveFileName+"/U2.dat", File.WRITE)
	var u2cells = U2.get_used_cells()
	for cell in u2cells:
		if int(increment/1024) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			Globals.UIPercentage = (float(increment) / float(u2cells.size()))*100
			dividedLines = int(increment/1024)
		increment += 1
		save_file.store_double(cell.x)
		save_file.store_double(cell.y)
		save_file.store_8(U2.get_cell(cell.x,cell.y))
	save_file.close()
	Globals.UIPercentage = -1
	print("[SAVE] Saved, U2 map has " + str(increment) + " tiles.")
	Globals.UIMsg = "Saving map (7/8): Player Data"
	yield(get_tree().create_timer(0.01), "timeout")
	print("[SAVE] Saving player data.")
	save_file = File.new()
	save_file.open("user://saves/"+SaveFileName+"/playerdata.dat", File.WRITE)
	save_file.store_var(Globals.Player)
	save_file.close()
	Globals.UIMsg = "Saving map (8/8): Metadata"
	if Exists == false:
		print("[SAVE] Saving metadata.")
		var date = OS.get_date()
		Globals.SaveMetadata.Created = str(date.month) + "/" + str(date.day) + "/" + str(date.year)
		save_file = File.new()
		save_file.open("user://saves/"+SaveFileName+"/metadata.dat", File.WRITE)
		save_file.store_var([Globals.SaveMetadata,Globals.MapData])
		save_file.close()
	Globals.UIMsg = ""
	Globals.UIPercentage = -1
	print("[SAVE] **** Save completed successfully.")
	
########################################################################
	
func Load(SaveFileName="map"):

	Globals.UIMsg = "Loading map (1/8): S0"
	yield(get_tree().create_timer(0.01), "timeout")

	var dividedLines = 0
	var increment = 0
	var save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/S0.dat"):
		print("[LOAD] S0 file does not exist.")
		var _new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(get_node("/root"), "S0 file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/S0.dat", File.READ)
	while save_file.get_position() != save_file.get_len():
		if int(increment/512) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			dividedLines = int(increment/512)
		increment += 1
		var tile = Vector2()
		tile.x = save_file.get_double()
		tile.y = save_file.get_double()
		var index = save_file.get_8()
		Globals.S0.set_cell(tile.x, tile.y, index)
		if index == 8:
			Globals.LightPlacements.Surface.append(Vector2(tile.x,tile.y))
	save_file.close()

	Globals.UIMsg = "Loading map (2/8): S1"
	yield(get_tree().create_timer(0.01), "timeout")

	dividedLines = 0
	increment = 0
	save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/S1.dat"):
		print("[LOAD] S1 file does not exist.")
		var new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(new_scene, "S1 file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/S1.dat", File.READ)
	while save_file.get_position() != save_file.get_len():
		if int(increment/512) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			dividedLines = int(increment/512)
		increment += 1
		var tile = Vector2()
		tile.x = save_file.get_double()
		tile.y = save_file.get_double()
		var index = save_file.get_8()
		Globals.S1.set_cell(tile.x, tile.y, index)
		if index == 8:
			Globals.LightPlacements.Surface.append(Vector2(tile.x,tile.y))
	save_file.close()
	
	Globals.UIMsg = "Loading map (3/8): S2"
	yield(get_tree().create_timer(0.01), "timeout")

	dividedLines = 0
	increment = 0
	save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/S2.dat"):
		print("[LOAD] S2 file does not exist.")
		var new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(new_scene, "S2 file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/S2.dat", File.READ)
	while save_file.get_position() != save_file.get_len():
		if int(increment/512) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			dividedLines = int(increment/512)
		increment += 1
		var tile = Vector2()
		tile.x = save_file.get_double()
		tile.y = save_file.get_double()
		var index = save_file.get_8()
		Globals.S2.set_cell(tile.x, tile.y, index)
		if index == 8:
			Globals.LightPlacements.Surface.append(Vector2(tile.x,tile.y))
	save_file.close()
	
	Globals.UIMsg = "Loading map (4/8): U0"
	yield(get_tree().create_timer(0.01), "timeout")
	
	dividedLines = 0
	increment = 0
	save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/U0.dat"):
		print("[LOAD] U0 file does not exist.")
		var new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(new_scene, "U0 file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/U0.dat", File.READ)
	while save_file.get_position() != save_file.get_len():
		if int(increment/512) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			dividedLines = int(increment/512)
		increment += 1
		var tile = Vector2()
		tile.x = save_file.get_double()
		tile.y = save_file.get_double()
		var index = save_file.get_8()
		Globals.U0.set_cell(tile.x, tile.y, index)
		if index == 8:
			Globals.LightPlacements.Cave.append(Vector2(tile.x,tile.y))
	save_file.close()

	Globals.UIMsg = "Loading map (5/8): U1"
	yield(get_tree().create_timer(0.01), "timeout")
	
	dividedLines = 0
	increment = 0
	save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/U1.dat"):
		print("[LOAD] U1 file does not exist.")
		var new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(new_scene, "U1 file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/U1.dat", File.READ)
	while save_file.get_position() != save_file.get_len():
		if int(increment/512) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			dividedLines = int(increment/512)
		increment += 1
		var tile = Vector2()
		tile.x = save_file.get_double()
		tile.y = save_file.get_double()
		var index = save_file.get_8()
		Globals.U1.set_cell(tile.x, tile.y, index)
		if index == 8:
			Globals.LightPlacements.Cave.append(Vector2(tile.x,tile.y))
	save_file.close()
	
	Globals.UIMsg = "Loading map (6/8): U2"
	yield(get_tree().create_timer(0.01), "timeout")
	
	dividedLines = 0
	increment = 0
	save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/U2.dat"):
		print("[LOAD] U2 file does not exist.")
		var new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(new_scene, "U2 file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/U2.dat", File.READ)
	while save_file.get_position() != save_file.get_len():
		if int(increment/512) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			dividedLines = int(increment/512)
		increment += 1
		var tile = Vector2()
		tile.x = save_file.get_double()
		tile.y = save_file.get_double()
		var index = save_file.get_8()
		Globals.U2.set_cell(tile.x, tile.y, index)
		if index == 8:
			Globals.LightPlacements.Cave.append(Vector2(tile.x,tile.y))
	save_file.close()
	
	Globals.UIMsg = "Loading map (7/8): Metadata"
	yield(get_tree().create_timer(0.01), "timeout")
	
	save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/metadata.dat"):
		print("[LOAD] Metadata file does not exist.")
		var new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(new_scene, "Metadata file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/metadata.dat", File.READ)
	var data = save_file.get_var(true)
	var saveData = data[0]
	var mapDataF = data[1]
	Globals.MapData = mapDataF
	Globals.SaveMetadata = saveData
	save_file.close()

	Globals.UIMsg = "Loading map (8/8): Player"
	yield(get_tree().create_timer(0.01), "timeout")
	
	save_file = File.new()
	if !save_file.file_exists("user://saves/"+SaveFileName+"/playerdata.dat"):
		print("[LOAD] Player Data file does not exist.")
		var new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(new_scene, "Player data file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+SaveFileName+"/playerdata.dat", File.READ)
	var plrData = save_file.get_var(true)
	Globals.Player = plrData
	save_file.close()
	
	Globals.MovementEnabled = true
	
	Globals.UIMsg = ""
	Globals.CurrentGameState = Globals.GameState.INGAME
