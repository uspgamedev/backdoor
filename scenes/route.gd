
extends Node

# Scenes
const RouteScene = preload("res://scenes/route.xscn")
const MapScene   = preload("res://scenes/map.xscn")

# Classes
const Body  = preload("res://model/body.gd")
const Actor = preload("res://model/actor.gd")

const preload_bodies = [
	["slime", Vector2(22,6), 10],
	["slime", Vector2(24,6), 10],
	["slime", Vector2(26,6), 10],
	["slime", Vector2(28,6), 10]
]

var current_sector
var player

static func load_from_file(file):
	var route = RouteScene.instance()
	route.player = Node.new()
	route.player.set_script(Actor)
	var map = MapScene.instance()
	route.get_node("sectors").add_child(map)
	var player_body = Body.new("hero", Vector2(22,8), 10)
	map.add_body(player_body)
	map.add_actor(player_body, route.player)
	for entry in preload_bodies:
		var body = Body.new(entry[0], entry[1], entry[2])
		map.add_body(body)
		map.add_actor(body, Actor.new())
	return route

func _init():
	print("route created")

func _ready():
	open_sector(null)
	print("route ready")

func change_sector(target):
	player = get_player() # removes from subtree
	close_current_sector()
	open_sector(target)
	set_player(player)

func get_player():
	return null

func close_current_sector():
	pass

func open_sector(target):
	var sectors = get_node("sectors")
	var sector = get_node("/root/sector")
	var map = sectors.get_child(0)
	sectors.remove_child(map)
	sector.add_child(map)
	sector.move_child(map, 0)
	map.set_fixed_process(true)
	sector.new_sector(player)

func set_player(player):
	pass
