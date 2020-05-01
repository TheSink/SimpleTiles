extends Node

enum DATA_MODE{MAP_CELLS,MAP_CHUNKS,VARIABLE}

func _ready():
	pass

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
	
func SaveData(save_name,file_name,mode,input_data):
	Globals.UIMsg = "Saving map: " + file_name
	print("[SAVE] Saving "+file_name+".")
	var save_file = File.new()
	var progress_increment = 0
	var increment = 0
	save_file.open("user://saves/"+save_name+"/"+file_name+".dat", File.WRITE)
	
	if mode == DATA_MODE.MAP_CELLS: # Save a map in cell-by-cell format
		var cells = input_data.get_used_cells()
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
