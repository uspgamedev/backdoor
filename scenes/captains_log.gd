
extends Node

const RouteScene = preload("res://scenes/route.xscn")

const Route = preload("res://scenes/route.gd")
const Actor = preload("res://model/actor.gd")
const Body = preload("res://model/body.gd")

onready var map_generator = get_node("map_generator")

var profile_data = {}

func _init():
	var profile = File.new()
	if profile.open("user://profile.meta", File.READ) == 0:
		profile_data.parse_json(profile.get_as_text())
		profile.close()
	else:
		profile_data["saves"] = []
	print("captain's log created")

func get_profile():
	return profile_data

func _ready():
	print("captain's log ready")

func route_id(id):
	return "route-" + var2str(int(id))

func find_free_route_id():
	var id = 1
	for route_id in profile_data["saves"]:
		if route_id != id:
			break
		id += 1
	return id

func create_route():
	var route = RouteScene.instance()
	route.id = find_free_route_id()
	profile_data["saves"].append(route.id)
	var w = 20
	var h = 20
	var map_node = map_generator.generate_map(w,h)
	route.get_node("sectors").add_child(map_node)
	route.current_sector = map_node
	var player = Actor.new("hero")
	route.player = player
	get_node("/root/sector").set_player(player)
	var player_body = Body.new(1, "hero", Vector2(10,10), 10)
	map_node.add_body(player_body)
	map_node.add_actor(player_body, player)
	get_parent().add_child(route)

func load_route(id):
	var file = File.new()
	if file.open("user://" + route_id(id) + ".save", File.READ) == 0:
		var route = Route.load_from_file(id, file)
		file.close()
		get_node("/root/sector").set_player(route.player)
		get_parent().call_deferred("add_child", route)
	else:
		print("Could not load save: " + id)

func finish():
	var file = File.new()
	if get_node("/root/").has_node("route"):
		var route = get_node("/root/route")
		file.open("user://" + route_id(route.id) + ".save", File.WRITE)
		route.save_to_file(file)
		file.close()
	file.open("user://profile.meta", File.WRITE)
	file.store_string(profile_data.to_json())
	file.close()
	get_tree().finish()
