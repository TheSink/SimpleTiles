extends Node2D

var WIDTH = 0
var HEIGHT = 0
var CurrentIndex = 0

var openSimplexNoise
var BiomeMap
var SavedTargetLayer = 0
var caves = []

func buttonSound():
	$Click.play()

func scanForButtons(path):
	for node in path.get_children():
		if (node.get_class() == "Button"):
			node.connect("pressed", self, "buttonSound")
		scanForButtons(node)

func newMap():
	WIDTH = Globals.MapData.Size
	HEIGHT = Globals.MapData.Size
	$Surface/S0.clear()
	$Surface/S2.clear()
	$Underground/U0.clear()
	randomize()
	openSimplexNoise = OpenSimplexNoise.new()
	openSimplexNoise.seed = Globals.MapData.Seed
	openSimplexNoise.octaves = Globals.MapData.Octaves
	openSimplexNoise.period = Globals.MapData.Period
	openSimplexNoise.lacunarity = Globals.MapData.Lacunarity
	openSimplexNoise.persistence = Globals.MapData.Persistence
	
	BiomeMap = OpenSimplexNoise.new()
	BiomeMap.seed = Globals.MapData.Seed+1
	BiomeMap.octaves = 2
	BiomeMap.period = 150
	BiomeMap.lacunarity = 1.5
	BiomeMap.persistence = 1

	_generate_world()

func check_surroundings(centerTile, checkFor):
	var found = false
	
	var neighbors = [Vector2(-1,1),Vector2(0,1),Vector2(1,1),
					Vector2(-1,0),Vector2(1,0),Vector2(-1,-1),
					Vector2(0,-1),Vector2(1,-1)]
					
	for vectorNear in neighbors:
		var currentTile = centerTile + vectorNear
		for tileIndex in checkFor:
			if $Surface/S0.get_cellv(currentTile) == tileIndex:
				found = true
	return found
	
func check_all_near(map, centerTile, checkFor):
	var number = 0
	
	var neighbors = [Vector2(-1,1),Vector2(0,1),Vector2(1,1),
					Vector2(-1,0),Vector2(1,0),Vector2(-1,-1),
					Vector2(0,-1),Vector2(1,-1)]
					
	for vectorNear in neighbors:
		var currentTile = centerTile + vectorNear
		if map.get_cellv(currentTile) != checkFor:
			number += 1
	return number
	
func place_near(centerTile, tileToPlace, tileMap):
	
	var neighbors = [Vector2(-1,1),Vector2(0,1),Vector2(1,1),
					Vector2(-1,0),Vector2(1,0),Vector2(-1,-1),
					Vector2(0,-1),Vector2(1,-1)]
					
	for vectorNear in neighbors:
		var currentTile = centerTile + vectorNear
		tileMap.set_cellv(currentTile, tileToPlace)

func fill(map, tileIndex, width, height):
	for x in range(0,width):
		for y in range(0,height):
			map.set_cell(x,y,tileIndex)

func place_random(map, tileIndex, chance, width, height):
	for x in range(1,width-1):
		for y in range(1,height-1):
			if Utilities.chance(chance):
				map.set_cell(x,y,tileIndex)
				
func generate_caves_initial():
	caves = []
	for x in range(0, WIDTH):
		for y in range(0, HEIGHT):
			if $Underground/U0.get_cell(x,y) == 9:
				var cave = []
				var to_fill = [Vector2(x,y)]
				while to_fill:
					var tile = to_fill.pop_back()
					
					if !cave.has(tile):
						cave.append(tile)
						$Underground/U0.set_cellv(tile, 3)
						
						for dir in [Vector2(tile.x, tile.y-1),Vector2(tile.x, tile.y+1),Vector2(tile.x+1, tile.y),Vector2(tile.x-1, tile.y)]:
							if $Underground/U0.get_cellv(dir) == 9:
								if !to_fill.has(dir) and !cave.has(dir):
									to_fill.append(dir)
				if cave.size() >= Globals.MapData.Caves.MinCaveSize:
					caves.append(cave)
	return caves

func _generate_world(): # ------------------------ Start of World Generation
	
	Globals.MovementEnabled = false
	
	print("Generating terrain.") # ----- Terrain -----
	Globals.UIMsg = "Generating terrain."
	var dividedLines = 0
	for x in WIDTH:
		if int(x/16) != dividedLines:
			yield(get_tree().create_timer(0.001), "timeout")
			dividedLines = int(x/16)
			Globals.UIPercentage = (x/WIDTH)*100
		for y in HEIGHT:
			$Surface/S0.set_cellv(Vector2(x, y), _get_tile_index(openSimplexNoise.get_noise_2d(x, y)))
			if BiomeMap.get_noise_2d(x,y) > 0.5: # Desert biome
				var index = _get_tile_index(openSimplexNoise.get_noise_2d(x, y))
				if index == 2 or index == 3 or index == 4: # Is ground/mountain
					$Surface/S0.set_cellv(Vector2(x, y), 7) # Generate sand
	print("Planting trees.") # ----- Trees -----
	if Globals.MapData.Flags.trees == true:
		Globals.UIMsg = "Planting trees."
		for x in WIDTH:
			if int(x/8) != dividedLines:
				yield(get_tree().create_timer(0.001), "timeout")
				dividedLines = int(x/8)
				Globals.UIPercentage = (x/WIDTH)*100
			for y in HEIGHT:
				if $Surface/S0.get_cellv(Vector2(x,y)) == 2:
					if randi()%30+1 == 1:
						if check_surroundings(Vector2(x,y), [0,3,5]) == false:
							$Surface/S0.set_cellv(Vector2(x,y), 5)
							$Surface/S2.set_cellv(Vector2(x,y), 6)
							place_near(Vector2(x,y), 6, $Surface/S2)
	print("Filling cave layer.") # ----- Cave Structure ----- #
	Globals.UIMsg = "Preparing caves."
	yield(get_tree().create_timer(0.01), "timeout")
	$Underground/U0.clear()
	fill($Underground/U0, 3, WIDTH, HEIGHT)
	place_random($Underground/U0, 9, Globals.MapData.Caves.GroundChance, WIDTH, HEIGHT)
	randomize()
	print("Carving out caves. Iterations: " + str(Globals.MapData.Caves.Iterations))
	Globals.UIMsg = "Carving cave locations."
	yield(get_tree().create_timer(0.01), "timeout")
	var iterations = Globals.MapData.Caves.Iterations
	for _i in range(iterations):
		var x = floor(rand_range(1, WIDTH-1))
		var y = floor(rand_range(1, HEIGHT-1))

		if check_all_near($Underground/U0, Vector2(x,y),3) > Globals.MapData.Caves.Neighbors:
			$Underground/U0.set_cell(x,y,3)
		elif check_all_near($Underground/U0, Vector2(x,y),3) < Globals.MapData.Caves.Neighbors:
			$Underground/U0.set_cell(x,y,9)
			
	Globals.UIMsg = "Carving caves (second pass)."
	yield(get_tree().create_timer(0.01), "timeout")
			
	generate_caves_initial()
				
	for cave in caves:
		for tile in cave:
			$Underground/U0.set_cellv(tile, 9)
	
	var TestMap = $Underground/U0.duplicate()
	add_child(TestMap)
	
	Globals.UIMsg = "Carving caves (third pass)."
	yield(get_tree().create_timer(0.01), "timeout")
	
	for x in range(1, WIDTH-1):
		for y in range(1, HEIGHT-1):
			if int(x/16) != dividedLines:
				yield(get_tree().create_timer(0.001), "timeout")
				dividedLines = int(x/16)
				Globals.UIPercentage = (x/WIDTH)*100

			for dir in [Vector2(x, y-1),Vector2(x, y+1),Vector2(x+1, y),Vector2(x-1, y)]:
				if TestMap.get_cellv(dir) == 9:
					$Underground/U0.set_cell(x,y,9)
					
					
	TestMap.queue_free()
	Globals.UIMsg = "Finalizing map."
	yield(get_tree().create_timer(0.01), "timeout")
	$Surface/S0.update_bitmask_region()
	$Surface/S0.fix_invalid_tiles()
	$Underground/U0.update_bitmask_region()
	$Underground/U0.fix_invalid_tiles()
	Globals.Maps.Surface.Root = $Surface
	Globals.Maps.Surface.Layers.S0 = $Surface/S0
	Globals.Maps.Surface.Layers.S2 = $Surface/S2
	Globals.Maps.Surface.Layers.U0 = $Underground/U0 # ----------------- End of World Generation
	
	Globals.UIMsg = ""
	Globals.UIPercentage = -1
	Globals.MovementEnabled = true
	Globals.CurrentGameState = Definitions.GameState.INGAME

func relayer():
	if SavedTargetLayer == 0:
		$SelectionMap.modulate = Color("8700ffed")
	elif SavedTargetLayer == 1:
		$SelectionMap.modulate = Color("87000eff")
	elif SavedTargetLayer == 2:
		$SelectionMap.modulate = Color("87cf00ff")

func _get_tile_index(noise_sample):
	if noise_sample < Globals.MapData.WD:
		return 0
	if noise_sample < Globals.MapData.WS:
		return 1
	if noise_sample < Globals.MapData.G:
		return 2
	if noise_sample < Globals.MapData.M:
		return 3
	if noise_sample < Globals.MapData.S:
		return 4
		
func _physics_process(_delta):
	if SavedTargetLayer != Globals.BuildTarget:
		SavedTargetLayer = Globals.BuildTarget
		relayer()
		
func _ready():
	Globals.Root = get_node("../")
	Globals.Maps.Surface.Layers.S0 = $Surface/S0
	Globals.Maps.Surface.Layers.S1 = $Surface/S1
	Globals.Maps.Surface.Layers.S2 = $Surface/S2
	Globals.Maps.Surface.Layers.U0 = $Underground/U0
	Globals.Maps.Surface.Layers.U1 = $Underground/U1
	Globals.Maps.Surface.Layers.U2 = $Underground/U2
	Globals.Maps.Surface.Root = $Surface
	Globals.Maps.Underground.Root = $Underground
	Globals.Time = 0
	$TickHandler.wait_time = Globals.MapData.TickSpeed
	
	if not Globals.Player.Position == Vector2(-1,-1):
		Globals.CurrentLayer = Globals.Player.Map
	else:
		Globals.CurrentLayer = 1
		
	if Globals.CurrentLayer == 1:
		$Underground.position += Vector2(100000,0)
	else:
		$Surface.position += Vector2(100000,0)
	
	scanForButtons(self)
	
	if Globals.CurrentGameState == Definitions.GameState.GENERATE:
		newMap()
		
	while Globals.CurrentGameState != Definitions.GameState.INGAME:
		yield(get_tree().create_timer(0.1), "timeout")
	
	for surface_light in Globals.LightPlacements.Surface:
		var light = Light2D.new()
		add_child(light)
		light.texture = load("res://torchlight.png")
		light.global_position = Globals.Maps.Surface.Layers.S0.map_to_world(surface_light)+Vector2(16,16)
		light.color = Color.orange
		light.energy = 1
		light.texture_scale = 1.5
		light.mode = Light2D.MODE_ADD
		if not Globals.CurrentLayer == 1: light.enabled = false
		Globals.LightReferences.Surface.append(light)
	for cave_light in Globals.LightPlacements.Underground:
		var light = Light2D.new()
		add_child(light)
		light.texture = load("res://torchlight.png")
		light.global_position = Globals.Maps.Surface.Layers.S0.map_to_world(cave_light)+Vector2(16,16)
		light.color = Color.orange
		light.energy = 1
		light.texture_scale = 1.5
		light.mode = Light2D.MODE_ADD
		if not Globals.CurrentLayer == 0: light.enabled = false
		Globals.LightReferences.Cave.append(light)
