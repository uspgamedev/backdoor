
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
	# Open file
	var data = {}
	# Parse to json
	var text = file.get_as_text()
	data.parse_json(text)
	var sectors = data["sectors"]
	for sector_data in sectors:
		# Parse sector
		var map = MapScene.instance()
		map.hide()
		route.get_node("sectors").add_child(map)
		# General sector info
		map.id = sector_data["id"]
		var width = sector_data["width"]
		var height = sector_data["height"]
		# Parse sector floor
		var floors = map.get_node("floors")
		floors.clear()
		var floor_data = sector_data["floors"]
		for j in range(floor_data.size()):
			floors.set_cell(j / int(width), j % int(width), floor_data[j])
		# Parse sector walls
		var walls = map.get_node("walls")
		walls.clear()
		var wall_data = sector_data["walls"]
		for j in range(wall_data.size()):
			walls.set_cell(j / int(width), j % int(width), wall_data[j])
		# Parse bodies
		var bodies = sector_data["bodies"]
		for body_data in bodies:
			var body = Body.new(body_data["type"], Vector2(body_data["pos"][0], body_data["pos"][1]), body_data["hp"])
			body.damage = body_data["damage"]
			map.add_body(body)
		# Parse actors
		var actors = sector_data["actors"]
		for actor_data in actors:
			var actor = Actor.new()
			actor.cooldown = actor_data["cooldown"]
			actor.draw_cooldown = actor_data["drawcooldown"]
			var hand = actor_data["hand"]
			for card in hand:
				actor.hand.append(Actor.Card.new(card))
			var deck = actor_data["deck"]
			for card in deck:
				actor.deck.append(Actor.Card.new(card))
			map.add_actor(map.bodies[actor_data["body_id"]], actor)
	# Set current sector
	route.current_sector = route.find_sector(data["current_sector"])
	route.current_sector.show()
	# Store reference to player
	route.player = route.current_sector.get_node("actors").get_child(data["player_actor_id"])
	# Set up camera
	route.current_sector.attach_camera(route.player)
	return route

func _init():
	print("route created")

func _ready():
	open_current_sector(null)
	print("route ready")

func find_sector(id):
	for sector in get_node("sectors").get_children():
		if sector.id == id:
			return sector
	if current_sector.id == id:
		return current_sector
	return null

func change_sector(target):
	var player_body = current_sector.get_actor_body(player)
	close_current_sector()
	current_sector = find_sector(target)
	open_current_sector(player_body)

func close_current_sector():
	var last = current_sector
	last.set_fixed_process(false)
	last.hide()
	last.remove_actor(player)
	get_node("/root/sector").remove_child(current_sector)
	get_node("sectors").add_child(last)

func open_current_sector(player_body):
	var sector = get_node("/root/sector")
	get_node("sectors").remove_child(current_sector)
	sector.add_child(current_sector)
	sector.move_child(current_sector, 0)
	current_sector.set_name("map")
	sector.new_sector(player)
	current_sector.set_fixed_process(true)
	current_sector.show()
	if player_body != null:
		current_sector.add_body(player_body)
		current_sector.add_actor(player_body, player)
		current_sector.move_actor(player, Vector2(0,0))

