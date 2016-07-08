
extends Node

const Map = preload("res://scenes/map.gd")
const MapGrid = preload("res://components/util/map_grid.gd")

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
    var map = MapGrid.new(w,h)

    # add random wall tiles
    map.add_random()
    map.add_random()
    map.add_random()

    # grow wall tiles

    # clean wall tiles

    # border/corner wall tiles

    # stuff
    var map_node = Map.create(id,w,h)
    var floors = map_node.get_node("floors")
    var walls = map_node.get_node("walls")
    for i in range(map.getWidth()):
        for j in range(map.getHeight()):
            floors.set_cell(j, i, 0)
            walls.set_cell(j, i, map.getTile(i, j))
    return map_node
