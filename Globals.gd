extends Node

enum GameState{MENU,GENERATE,LOAD,INGAME,PAUSED}

var version = "0.1.2"
var Surface = Node2D.new()
var Underground = Node2D.new()
var S0 = TileMap.new()
var S1 = TileMap.new()
var S2 = TileMap.new()
var U0 = TileMap.new()
var U1 = TileMap.new()
var U2 = TileMap.new()
var SelectionMap = TileMap.new()
var Root = Node2D.new()
var UIMsg = ""
var UIPercentage = -1
var CurrentLayer = 1
var Time = 0
var SettingsOpen = false
var CreditsOpen = false
var MovementEnabled = true
var NumberErrors = 0
var TicksElapsed = 0
var BuildTarget = 0
var CurrentGameState = GameState.MENU
var PlayerBody

var BlockTextures = {
	"Deep_Water": ["res://Tiles/water_deep.png",1],
	"Shallow_Water": ["res://Tiles/water_shallow.png",1],
	"Grass": ["res://Tiles/grass.png",1],
	"Mountain": ["res://Tiles/mountain.png",1],
	"Snow": ["res://Tiles/snow.png",1],
	"Tree": ["res://Tiles/tree.png",1],
	"Leaves": ["res://Tiles/leaves.png",2],
	"Sand": ["res://Tiles/sand.png",1],
	"Torch": ["res://Tiles/torch.png",0],
	"Cave_Floor": ["res://Tiles/cave_ground.png",0]
}

var Music = {
	"nautilus": ["res://Music/nautilus.ogg", 1, 217],
	"osare": ["res://Music/osare.ogg", 1, 307],
	"perces": ["res://Music/perces.ogg", 1, 140],
	"emptycity": ["res://Music/emptycity.ogg", 0, 101],
	"ominous": ["res://Music/ominous.ogg", 0, 88],
	"wonderlust": ["res://Music/wonderlust.ogg", 0, 147]
}

var LightReferences = {
	Cave = [],
	Surface = []
}

var Player = {
	Position = Vector2(-1,-1),
	Map = 1,
	Equipped = [-1,0], # Block ID, Amount
	Stored = {
		
	}
}

var SaveMetadata = {
	Name = "",
	Description = "",
	Size = "",
	Created = "",
	Version = ""
}

var BlockChecks = {
	TreeLeaves = []
}

var MapData = {
	Size = 256,
	TickSpeed = 3,
	Octaves = 4,
	Period = 15,
	Lacunarity = 1.5,
	Persistence = 0.75,
	Seed = 0,
	WD = 0.1,
	WS = 0.3,
	G = 0.6,
	M = 0.7,
	S = 0.9,
	Caves = {
		Iterations = 20000,
		Neighbors = 4,
		GroundChance = 48,
		MinCaveSize = 32
	},
	Flags = {
		trees = true,
		foliage = true,
		cave_ores = false,
		day_night = false,
		animals = false,
		enemies = false
	}
}

var LightPlacements = {
	Cave = [],
	Surface = []
}

func _lower_errors():
	NumberErrors -= 1

func DisplayErrorPopup(root, errorMsg):
	if NumberErrors < 1:
		NumberErrors += 1
		var gameState = str(CurrentGameState)
		if gameState == "0":
			gameState = "MENU"
		elif gameState == "1":
			gameState = "GENERATE"
		elif gameState == "2":
			gameState = "LOAD"
		elif gameState == "3":
			gameState = "INGAME"
		elif gameState == "4":
			gameState = "PAUSED"
		var message = load("res://MessageBox.tscn").instance()
		root.add_child(message)
		var state = message.get_node("State")
		state.text = "Occurred during state: " + str(CurrentGameState)
		var error = message.get_node("ErrorMessage")
		error.text = errorMsg
		message.popup()
		message.connect("popup_hide", self, "_lower_errors")
