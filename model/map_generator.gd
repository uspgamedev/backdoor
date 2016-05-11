
extends Node

const MapScene = preload("res://scenes/map.xscn")

const EMPTY = 0
const FLOOR = 1
const Wall = 2

func _ready():
	pass

func generate_map(id,w,h):
	var map = [];
	map.resize(h)
	for i in range(w):
		map[i] = []
		map[i].resize(w)
		for j in range(h):
			map[i][j] = 1
	# stuff
	var map_node = MapScene.instance()
	map_node.get_node("floors").clear()
	map_node.get_node("walls").clear()
	map_node.width = w
	map_node.height = h
	map_node.id = id
	var floors = map_node.get_node("floors")
	for i in range(map.size()):
		for j in range(map[i].size()):
			floors.set_cell(j, i, 0)
	return map_node
