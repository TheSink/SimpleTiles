extends Control

var tree
var doTrees
var doFoliage
var doCycle
var octaves
var persistence
var lacunarity
var period
var genSeed
var dwt
var swt
var gt
var mt
var st
var selectedLevel
var settingsNode
var tickSpeed
var settingsOpen = false

func _create_range(obj_tree, root, property_name, value, minimum, maximum, increment, enabled=true):
	var property = obj_tree.create_item(root)
	property.set_cell_mode(1,TreeItem.CELL_MODE_RANGE)
	property.set_text(0,property_name)
	property.set_range_config(1, minimum, maximum, increment)
	property.set_range(1,value)
	property.set_editable(1,enabled)
	return property

func _create_bool(obj_tree, root, property_name, checked, enabled=true):
	var property = obj_tree.create_item(root)
	property.set_cell_mode(1,TreeItem.CELL_MODE_CHECK)
	property.set_text(0,property_name)
	property.set_checked(1,checked)
	property.set_editable(1,enabled)
	return property

func buttonSound():
	$Click.play()

func _ready():
	ProjectSettings.set_setting("application/config/version", Globals.version)
	$"WorldSelect/TabContainer/Load World/ItemList".clear()
	var saves = SaveLoad.GetSaves()
	for saveFileName in saves:
		$"WorldSelect/TabContainer/Load World/ItemList".add_item(saveFileName)
	if saves.size() == 0:
		$WorldSelect/TabContainer.current_tab = 1
	
	tree = $"WorldSelect/TabContainer/Create New World/Tree"
	var root = tree.create_item()
	root.set_text(0,"World Settings")
	randomize()
	genSeed = _create_range(tree, root, "Seed", rand_range(0,99999999), 0, 99999999, 1)
	tickSpeed = _create_range(tree,root,"Tick Speed",ProjectSettings.get_setting("game/settings/tick/speed"), 0.5, 16, 0.5)
	var surfaceflags = tree.create_item(root)
	surfaceflags.set_text(0, "Flags")
	doTrees = _create_bool(tree, surfaceflags, "Generate Trees", true)
	doFoliage = _create_bool(tree, surfaceflags, "Generate Foliage (Disabled)", false,false)
	var _doCaveOres = _create_bool(tree, surfaceflags, "Generate Cave Ores (Disabled)", false,false)
	doCycle = _create_bool(tree, surfaceflags, "Enable Day/Night Cycle", true)
	var _doAnimals = _create_bool(tree, surfaceflags, "Spawn Animals (Disabled)", false,false)
	var _doEnemies = _create_bool(tree, surfaceflags, "Spawn Enemies (Disabled)", false,false)
	var surfacegen = tree.create_item(root)
	surfacegen.set_text(0,"Generator (Advanced)")
	octaves = _create_range(tree, surfacegen, "Octaves", 4, 1, 9, 1)
	period = _create_range(tree, surfacegen, "Period", rand_range(38,44), 10, 400, 1)
	lacunarity = _create_range(tree, surfacegen, "Lacunarity", 2, 0.1, 5, 0.1)
	persistence = _create_range(tree, surfacegen, "Persistence", 0.5, 0, 1, 0.01)
	var surfacetol = tree.create_item(root)
	surfacetol.set_text(0,"Tolerances (Advanced)")
	dwt = _create_range(tree, surfacetol, "Deep Water", rand_range(0.04,0.07), 0.01, 0.99, 0.01)
	swt = _create_range(tree, surfacetol, "Shallow Water", rand_range(0.2,0.26), 0.01, 0.99, 0.01)
	gt = _create_range(tree, surfacetol, "Grass", rand_range(0.48,0.57), 0.01, 0.99, 0.01)
	mt = _create_range(tree, surfacetol, "Mountain", rand_range(0.66,0.7), 0.01, 0.99, 0.01)
	st = _create_range(tree, surfacetol, "Snow", rand_range(0.86,0.91), 0.01, 0.99, 0.01)
	$MainMenu/VersionText.text = "Version " + ProjectSettings.get("application/config/version")
	
	print("Game version is " + ProjectSettings.get("application/config/version"))
	
	print("Loading audio bus volume configuration.")
	AudioServer.set_bus_volume_db(0, -80-((ProjectSettings.get_setting("audio/master_volume")/100)*-80))
	AudioServer.set_bus_volume_db(1, -80-((ProjectSettings.get_setting("audio/music_volume")/100)*-80))
	AudioServer.set_bus_volume_db(2, -80-((ProjectSettings.get_setting("audio/footstep_volume")/100)*-80))
	print("Successfully loaded audio bus volume configuration.")
	
	scanForButtons(self)

func scanForButtons(path):
	for node in path.get_children():
		if (node.get_class() == "Button"):
			node.connect("pressed", self, "buttonSound")
		scanForButtons(node)

func _on_Button2_pressed(): # Quit Button
	get_tree().quit()


func _on_Button_pressed(): # Play Button
	$MainMenu.visible = false
	$WorldSelect.visible = true


func _on_Button3_pressed(): # World Select Back Button
	$MainMenu.visible = true
	$WorldSelect.visible = false


func _on_Size_value_changed(value):
	if value > 1100:
		$"WorldSelect/TabContainer/Create New World/SizeLabel".modulate = Color(1,0,0)
	elif value > 700:
		$"WorldSelect/TabContainer/Create New World/SizeLabel".modulate = Color(1,1,0)
	else:
		$"WorldSelect/TabContainer/Create New World/SizeLabel".modulate = Color(1,1,1)
		
	$"WorldSelect/TabContainer/Create New World/SizeLabel".text = str(value) + "x" + str(value)


func _on_Create_pressed(): # Create World Button
	Globals.CurrentGameState = Globals.GameState.GENERATE
	Globals.MapData.Size = $"WorldSelect/TabContainer/Create New World/Size".value
	Globals.MapData.TickSpeed = tickSpeed.get_range(1)
	Globals.MapData.Octaves = octaves.get_range(1)
	Globals.MapData.Period = period.get_range(1)
	Globals.MapData.Lacunarity = lacunarity.get_range(1)
	Globals.MapData.Persistence = persistence.get_range(1)
	Globals.MapData.Seed = genSeed.get_range(1)
	Globals.MapData.WD = dwt.get_range(1)
	Globals.MapData.WS = swt.get_range(1)
	Globals.MapData.G = gt.get_range(1)
	Globals.MapData.M = mt.get_range(1)
	Globals.MapData.S = st.get_range(1)
	Globals.MapData.Flags.trees = doTrees.is_checked(1)
	Globals.MapData.Flags.foliage = doFoliage.is_checked(1)
	Globals.MapData.Flags.day_night = doCycle.is_checked(1)
	Globals.CurrentGameState = Globals.GameState.GENERATE
	var saveName = $"WorldSelect/TabContainer/Create New World/Name".text
	Globals.SaveMetadata.Name = saveName.replace(" ", "_")
	Globals.SaveMetadata.Description = $"WorldSelect/TabContainer/Create New World/Description".text
	Globals.SaveMetadata.Size = $"WorldSelect/TabContainer/Create New World/SizeLabel".text
	Globals.SaveMetadata.Created = str(OS.get_date())
	var _new_scene = get_tree().change_scene("res://World.tscn")


func _on_ItemList_item_selected(index):
	var fileName = $"WorldSelect/TabContainer/Load World/ItemList".get_item_text(index)
	var meta = File.new()
	if meta.file_exists("user://saves/"+fileName+"/metadata.dat"):
		$"WorldSelect/TabContainer/Load World/PanelCover".visible = false
		meta.open("user://saves/"+fileName+"/metadata.dat", File.READ)
		selectedLevel = fileName
		var data = meta.get_var(true)
		data = data[0]
		$"WorldSelect/TabContainer/Load World/Panel/WorldTitle".text = data.Name
		$"WorldSelect/TabContainer/Load World/Panel/Description".text = "Description: \n\n" + data.Description
		$"WorldSelect/TabContainer/Load World/Panel/CreatedDate".text = "Created on " + data.Created
		$"WorldSelect/TabContainer/Load World/Panel/MapSize".text = "Map Size: " + data.Size
		$"WorldSelect/TabContainer/Load World/Panel/PlayButton".text = "Play " + data.Name


func _on_PlayButton_pressed():
	print("Loading world:" + selectedLevel)
	var _new_scene = get_tree().change_scene("res://World.tscn")
	Globals.CurrentGameState = Globals.GameState.LOAD
	SaveLoad.LoadGame(selectedLevel)

func _on_Button5_pressed():
	if Globals.CreditsOpen == false:
		Globals.CreditsOpen = true
		add_child(load("res://UI/CreditsMenu.tscn").instance())


func _on_Settings_pressed():
	if Globals.SettingsOpen == false:
		Globals.SettingsOpen = true
		add_child(load("res://UI/SettingsMenu.tscn").instance())
		
func _physics_process(_delta):
	$Sprite.position += Vector2(-0.25,0.25)
	if $Sprite.position.x < 544:
		$Sprite.position = Vector2(800,450)


func _on_DeleteAllButton_pressed():
	$DeleteAllPopup.visible = true


func _on_DeleteButton_pressed():
	$DeleteOnePopup/Main/Label.text = "You are about to delete the save '"+selectedLevel+"'. Are you sure?"
	$DeleteOnePopup.visible = true


func _on_No_pressed():
	$DeleteAllPopup.visible = false
	$DeleteOnePopup.visible = false


func _on_YesAll_pressed():
	var saveScan = []
	var dir = Directory.new()
	if dir.dir_exists("user://saves/"):
		dir.open("user://saves/")
		dir.list_dir_begin()
		var save_file = dir.get_next()
		while save_file != "":
			if not "." in save_file:
				print("Save file queued for deletion: " + save_file)
				saveScan.append("user://saves/"+save_file)
			save_file = dir.get_next()
	dir.list_dir_end()
	for save in saveScan:
		dir.open(save)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not file_name.substr(0,1) == ".":
				dir.remove(save + "/" + file_name)
			file_name = dir.get_next()
	for save in saveScan:
		dir.remove(save)
		print(save + " DELETED")
	$"WorldSelect/TabContainer/Load World/ItemList".clear()
	var saves = SaveLoad.GetSaves()
	for saveFileName in saves:
		$"WorldSelect/TabContainer/Load World/ItemList".add_item(saveFileName)
	$DeleteAllPopup.visible = false
	$"WorldSelect/TabContainer/Load World/PanelCover".visible = true


func _on_YesOne_pressed():
	var dir = Directory.new()
	if dir.dir_exists("user://saves/"+selectedLevel):
		dir.open("user://saves/"+selectedLevel)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not file_name.substr(0,1) == ".":
				dir.remove("user://saves/"+selectedLevel+"/"+file_name)
			file_name = dir.get_next()
		dir.open("user://saves")
		dir.remove("user://saves/"+selectedLevel)
		$"WorldSelect/TabContainer/Load World/ItemList".clear()
		var saves = SaveLoad.GetSaves()
		for saveFileName in saves:
			$"WorldSelect/TabContainer/Load World/ItemList".add_item(saveFileName)
	$DeleteOnePopup.visible = false
	$"WorldSelect/TabContainer/Load World/PanelCover".visible = true
