
extends Node

const Map = preload("res://scenes/map.gd")
const MapGrid = preload("res://components/util/map_grid.gd")

func _ready():
    pass

func generate_map(id,w,h):
    var map = MapGrid.new(w,h)
    var file = File.new()
    var grow_patterns = {}
    var clean_patterns = {}
    var text = ""

    # read grow pattern json
    file.open("res://components/util/patterns/growing_patterns.json", File.READ)
    text = file.get_as_text()
    grow_patterns.parse_json(text)
    file.close()

    # add random wall tiles
    map.add_random()
    map.add_random()
    map.add_random()

    # grow wall tiles
    map.apply_pattern_rules(grow_patterns.patterns, 1)
    map.apply_pattern_rules(grow_patterns.patterns, 1)
    map.apply_pattern_rules(grow_patterns.patterns, 1)

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
