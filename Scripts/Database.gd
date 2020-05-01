extends Node

enum E_TYPE{
	TILE,
	ITEM,
	ABILITY
}

var Database = {
	"Deep_Water": {
		ID = 0,
		TYPE = E_TYPE.TILE,
		DESCRIPTION = "A tile of deep water that often makes up a large body of water.",
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
		DESCRIPTION = "A tile of water, found naturally along the coast of land bodies (as a transition from deep water to land).",
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
		DESCRIPTION = "A grass tile that generates on land in plains/forest biomes.",
		FLAGS = {
			MINE = true,
			BUILD = true,
			HARVEST = false
		},
		TEXTURE = "res://Tiles/grass.png"
	}
}
