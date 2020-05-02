extends Node

enum DATA_MODE{MAP_CELLS,MAP_CHUNKS,VARIABLE}

func _ready():
	pass

func CreateSaveFolder(folder_name):
	var dir = Directory.new()
	if not dir.dir_exists("user://saves/"+folder_name):
		print("[SAVE] Directory not found for map, creating.")
		dir.open("user://saves/")
		dir.make_dir(folder_name)
	else:
		print("[SAVE] Directory already exists. Ignoring.")
	dir.list_dir_end()

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
	
func RegisterLightObject(map, location):
	if map == Definitions.MapLayer.SURFACE:
		Globals.LightPlacements.Surface.append(location)
	elif map == Definitions.MapLayer.UNDERGROUND:
		Globals.LightPlacements.Underground.append(location)
	
func SaveData(save_name,file_name,mode,input_data,layer=null):
	Globals.UIMsg = "Saving: " + file_name
	print("[SAVE] Saving "+file_name+".")
	var save_file = File.new()
	var progress_increment = 0
	var increment = 0
	save_file.open("user://saves/"+save_name+"/"+file_name+".dat", File.WRITE)
	
	if mode == DATA_MODE.MAP_CELLS: # Save a map in cell-by-cell format
		
		save_file.store_var(layer) # Save map layer (surface or underground) for easier reading
		
		var cells = input_data.get_used_cells() # Increment over each tile and store data
		for cell in cells:
			if int(increment/1024) != progress_increment:
				yield(get_tree().create_timer(0.001), "timeout")
				Globals.UIPercentage = (float(increment) / float(cells.size()))*100
				progress_increment = int(increment/1024)
			increment += 1
			save_file.store_double(cell.x)
			save_file.store_double(cell.y)
			save_file.store_8(input_data.get_cell(cell.x,cell.y))
			
	elif mode == DATA_MODE.MAP_CHUNKS: # Save a map in chunk format (WIP)
		pass
		
	elif mode == DATA_MODE.VARIABLE: # Save a variable, array, dictionary, etc.
		save_file = File.new()
		save_file.open("user://saves/"+save_name+"/"+file_name+".dat", File.WRITE)
		save_file.store_var(input_data)
		
	save_file.close()

func LoadData(save_name,file_name,mode,output=null):
	Globals.UIMsg = "Loading: " + file_name
	var progress_increment = 0
	var increment = 0
	var save_file = File.new()
	
	if !save_file.file_exists("user://saves/"+save_name+"/"+file_name+".dat"): #Confirm file exists
		print("[LOAD] S0 file does not exist.")
		var _new_scene = get_tree().change_scene("res://MenuRoot.tscn")
		Globals.DisplayErrorPopup(get_node("/root"), "S0 file does not exist. Load failed.")
		return
	save_file.open("user://saves/"+save_name+"/"+file_name+".dat", File.READ)
	
	if mode == DATA_MODE.MAP_CELLS:
		var layer = save_file.get_var()
		
		while save_file.get_position() != save_file.get_len(): # Loop over each cell and load data
			if int(increment/512) != progress_increment:
				yield(get_tree().create_timer(0.001), "timeout")
				progress_increment = int(increment/512)
			increment += 1
			var tile = Vector2()
			tile.x = save_file.get_double()
			tile.y = save_file.get_double()
			var index = save_file.get_8()
			output.set_cell(tile.x, tile.y, index)
			if index == 8:
				RegisterLightObject(layer, Vector2(tile.x, tile.y)) # Register light coordinates to be spawned by the world manager.
	elif mode == DATA_MODE.VARIABLE:
		var data = save_file.get_var(true)
		return data
	save_file.close()

func SaveGame(save_name):
	CreateSaveFolder(save_name)
	# Save all surface maps to file
	SaveData(save_name,"S0",DATA_MODE.MAP_CELLS,Globals.S0,Definitions.MapLayer.SURFACE)
	SaveData(save_name,"S1",DATA_MODE.MAP_CELLS,Globals.S1,Definitions.MapLayer.SURFACE)
	SaveData(save_name,"S2",DATA_MODE.MAP_CELLS,Globals.S2,Definitions.MapLayer.SURFACE)
	# Save all underground maps to file
	SaveData(save_name,"U0",DATA_MODE.MAP_CELLS,Globals.U0,Definitions.MapLayer.UNDERGROUND)
	SaveData(save_name,"U1",DATA_MODE.MAP_CELLS,Globals.U1,Definitions.MapLayer.UNDERGROUND)
	SaveData(save_name,"U2",DATA_MODE.MAP_CELLS,Globals.U2,Definitions.MapLayer.UNDERGROUND)
	# Save metadata/player information
	SaveData(save_name,"PlayerData",DATA_MODE.VARIABLE,Globals.Player)
	SaveData(save_name,"Metadata",DATA_MODE.VARIABLE,[Globals.SaveMetadata,Globals.MapData])
	
	Globals.UIMsg = ""
	Globals.UIPercentage = -1 # Replace Globals.UI* stuff when the UIActions module is created

func LoadGame(save_name):
	# Load all surface maps
	LoadData(save_name, "S0", DATA_MODE.MAP_CELLS, Globals.S0)
	LoadData(save_name, "S1", DATA_MODE.MAP_CELLS, Globals.S1)
	LoadData(save_name, "S2", DATA_MODE.MAP_CELLS, Globals.S2)
	# Load all underground maps
	LoadData(save_name, "U0", DATA_MODE.MAP_CELLS, Globals.U0)
	LoadData(save_name, "U1", DATA_MODE.MAP_CELLS, Globals.U1)
	LoadData(save_name, "U2", DATA_MODE.MAP_CELLS, Globals.U2)
	# Load metadata/player information
	var player_data = LoadData(save_name, "PlayerData", DATA_MODE.VARIABLE)
	var metadata = LoadData(save_name, "Metadata", DATA_MODE.VARIABLE)
	Globals.SaveMetadata = metadata[0]
	Globals.MapData = metadata[1]
	Globals.Player = player_data
