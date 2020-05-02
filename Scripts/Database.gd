extends Node

enum E_TYPE{
	TILE,
	ITEM
}

var Database = {
	"Deep_Water": {
		ID = 0,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Often makes up a large body of water.",
		FLAGS = {
			MINE = false,
			BUILD = false,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/water_deep.png"
	},
	"Water": {
		ID = 1,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Found naturally along the coast of land bodies (as a transition from deep water to land).",
		FLAGS = {
			MINE = false,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/water_shallow.png"
	},
	"Grass": {
		ID = 2,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Generates on land in plains/forest biomes, makes up a large portion of the ground",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/grass.png"
	},
	"Stone": {
		ID = 3,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Makes up mountains and the walls of caves.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/stone.png"
	},
	"Snow": {
		ID = 4,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Forms in cold climates and slows player movement.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/snow.png"
	},
	"Wood": {
		ID = 5,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Generated as tree bark, can be taken and used as building material.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/wood.png"
	},
	"Leaves": {
		ID = 6,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Generates while building trees.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/leaves.png"
	},
	"Sand": {
		ID = 7,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Generates on the coast of land masses.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/sand.png"
	},
	"Torch": {
		ID = 7,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Generates on the coast of land masses.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/sand.png"
	},
	"DarkStone": {
		ID = 8,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "Darker form of the stone tile, naturally generating as ground tiles in caves.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/cave_ground.png"
	}
}
