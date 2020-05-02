extends Node

var WIDTH = 0
var HEIGHT = 0
var terrain_map
var biome_map = {
	desert = OpenSimplexNoise.new()
}

func GenerateNoiseMap(size):
	WIDTH = Globals.MapData.Size
	HEIGHT = Globals.MapData.Size
	$Surface/S0.clear()
	$Surface/S2.clear()
	$Underground/U0.clear()
	randomize()
	terrain_map = OpenSimplexNoise.new()
	terrain_map.seed = Globals.MapData.Seed
	terrain_map.octaves = Globals.MapData.Octaves
	terrain_map.period = Globals.MapData.Period
	terrain_map.lacunarity = Globals.MapData.Lacunarity
	terrain_map.persistence = Globals.MapData.Persistence
	
	biome_map.desert = OpenSimplexNoise.new()
	biome_map.desert.seed = Globals.MapData.Seed+1
	biome_map.desert.octaves = 2
	biome_map.desert.period = 150
	biome_map.desert.lacunarity = 1.5
	biome_map.desert.persistence = 1
