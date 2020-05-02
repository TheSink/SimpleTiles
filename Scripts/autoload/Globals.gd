extends Node

var version = "0.1.2"
onready var CurrentGameState = Definitions.GameState.MENU


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
var PlayerBody

var Maps = { # Global reference to the maps that store the world tiles.
	Surface = {
		Root = Node2D.new(),
		Layers = {
			S0 = TileMap.new(),
			S1 = TileMap.new(),
			S2 = TileMap.new()
		}
	},
	Underground = {
		Root = Node2D.new(),
		Layers = {
			U0 = TileMap.new(),
			U1 = TileMap.new(),
			U2 = TileMap.new()
		}
	}
}

var BlockTextures = { # Dictionary of the tiles that can be placed/broken, soon to be replaced with the Database singleton.
	"Deep Water": ["res://Tiles/water_deep.png",1],
	"Shallow Water": ["res://Tiles/water_shallow.png",1],
	"Grass": ["res://Tiles/grass.png",1],
	"Stone": ["res://Tiles/stone.png",1],
	"Snow": ["res://Tiles/snow.png",1],
	"Wood": ["res://Tiles/wood.png",1],
	"Leaves": ["res://Tiles/leaves.png",2],
	"Sand": ["res://Tiles/sand.png",1],
	"Torch": ["res://Tiles/torch.png",0],
	"Dark Stone": ["res://Tiles/dark_stone.png",0]
}

var Music = { # Game music, including: path, layer to play on, and length
	"nautilus": ["res://Music/nautilus.ogg", 1, 217],
	"osare": ["res://Music/osare.ogg", 1, 307],
	"perces": ["res://Music/perces.ogg", 1, 140],
	"emptycity": ["res://Music/emptycity.ogg", 0, 101],
	"ominous": ["res://Music/ominous.ogg", 0, 88],
	"wonderlust": ["res://Music/wonderlust.ogg", 0, 147]
}

var LightReferences = { # A reference to the actual light nodes.
	Cave = [],
	Surface = []
}

var LightPlacements = { # A list of light position coordinates, either for tracking or reloading when a map is loaded.
	Underground = [],
	Surface = []
}

var Player = { # Player metadata
	Health = 100,
	Position = Vector2(-1,-1),
	Map = 1,
	EXP = 0,
	Equipped = [-1,0], # Block ID, Amount
	Stored = {
		
	}
}

var SaveMetadata = { # Save file metadata
	Name = "",
	Description = "",
	Size = "",
	Created = "",
	Version = ""
}

var BlockChecks = { # Array of blocks to be checked during tick
	TreeLeaves = [] # For tree leaf decay
}

var MapData = { # Generator configuration, will not be needed once WorldGeneration module is finished.
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

func _lower_errors():
	NumberErrors -= 1

func DisplayErrorPopup(root, errorMsg): # Rewrite and move to UIActions module is needed
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
