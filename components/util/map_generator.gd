
extends Node

const Map = preload("res://scenes/map.gd")

const EMPTY = -1
const FLOOR = 0

const WALL = 1

const WALL_TOP = 2
const WALL_TOP_RIGHT = 3
const WALL_RIGHT = 4
const WALL_BOTTOM_RIGHT = 5
const WALL_BOTTOM = 6
const WALL_BOTTOM_LEFT = 7
const WALL_LEFT = 8
const WALL_TOP_LEFT = 9

const WALL_CORNER_TOP_RIGHT = 10
const WALL_CORNER_BOTTOM_RIGHT = 11
const WALL_CORNER_BOTTOM_LEFT = 12
const WALL_CORNER_TOP_LEFT = 13

func _ready():
    pass

func _iterate_and_compare_pattern(map, pattern, tile):
    for i in range(map.size()):
        for j in range(map[i].size()):
            for di in [ -1, 2 ]:
                for dj in [ -1, 2 ]:
                    if map[i+di][j+dj] == pattern[di+1][dj+1]:
                        map[i][j] = tile


func generate_map(id,w,h):
    var map = [];
    map.resize(h)
    for i in range(w):
        map[i] = []
        map[i].resize(w)
        for j in range(h):
            map[i][j] = 1
    # stuff
    var map_node = Map.create(id,w,h)
    var floors = map_node.get_node("floors")
    var walls = map_node.get_node("walls")
    for i in range(map.size()):
        for j in range(map[i].size()):
            floors.set_cell(j, i, FLOOR)
            if randf() > .9:
                walls.set_cell(j, i, WALL)
    return map_node
