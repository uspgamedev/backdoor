
extends Node

const Map = preload("res://scenes/map.gd")
const MapGrid = preload("res://components/util/map_grid.gd")

func _ready():
    pass

func get_json_pattern_in_text(filename):
    var dict = {}
    var file = File.new()
    var text = ""
    file.open("res://components/util/patterns/" + filename + ".json", File.READ)
    text = file.get_as_text()
    dict.parse_json(text)
    file.close()
    return dict

func generate_map(id,w,h):
    var map = MapGrid.new(w,h)
    var growing_patterns = get_json_pattern_in_text("growing_patterns")
    var cleaning_patterns = get_json_pattern_in_text("cleaning_patterns")
    var border_patterns = get_json_pattern_in_text("border_patterns")

    # add random wall tiles
    map.add_random()
    map.add_random()
    map.add_random()

    # grow wall tiles
    map.apply_pattern_rules(growing_patterns.patterns, growing_patterns.value)
    map.apply_pattern_rules(growing_patterns.patterns, growing_patterns.value)
    map.apply_pattern_rules(growing_patterns.patterns, growing_patterns.value)

    # clean wall tiles
    map.apply_pattern_rules(cleaning_patterns.patterns, cleaning_patterns.value)
    map.apply_pattern_rules(cleaning_patterns.patterns, cleaning_patterns.value)
    map.apply_pattern_rules(cleaning_patterns.patterns, cleaning_patterns.value)

    # border/corner wall tiles
    for rule in border_patterns:
        map.apply_pattern_rules(border_patterns[rule].patterns, border_patterns[rule].value)

    # stuff
    var map_node = Map.create(id,w,h)
    var floors = map_node.get_node("floors")
    var walls = map_node.get_node("walls")
    for i in range(map.get_width()):
        for j in range(map.get_height()):
            floors.set_cell(j, i, 0)
            walls.set_cell(j, i, map.get_tile(i, j))
    return map_node
