
extends Node

# Scenes
const RouteScene = preload("res://scenes/route.xscn")

# Classes
const Identifiable = preload("res://model/identifiable.gd")
const Body         = preload("res://model/body.gd")
const Actor        = preload("res://model/actor.gd")
const Map          = preload("res://scenes/map.gd")

var current_sector
var player
var id

static func get_player_name_from_file(file):
	# Open file
	var data = {}
	# Parse to json
	var text = file.get_as_text()
	data.parse_json(text)
	file.close()
	var sector_data
	for sector in data["sectors"]:
		if sector["id"] == data["current_sector"]:
			sector_data = sector
	return sector_data["actors"][int(data["player_actor_id"])]["name"]

static func load_from_file(id, file):
	var route = RouteScene.instance()
	route.id = id
	# Open file
	var data = {}
	# Parse to json
	var text = file.get_as_text()
	data.parse_json(text)
	var sectors = data["sectors"]
	for sector_data in sectors:
		# Parse sector
		var map = Map.create(sector_data["id"], sector_data["width"], sector_data["height"])
		route.get_node("sectors").add_child(map)
		# General sector info
		# Parse sector floor
		var floors = map.get_node("floors")
		floors.clear()
		var floor_data = sector_data["floors"]
		for j in range(floor_data.size()):
			floors.set_cell(j / int(map.width), j % int(map.width), floor_data[j])
		# Parse sector walls
		var walls = map.get_node("walls")
		walls.clear()
		var wall_data = sector_data["walls"]
		for j in range(wall_data.size()):
			walls.set_cell(j / int(map.width), j % int(map.width), wall_data[j])
		# Parse bodies
		var bodies = sector_data["bodies"]
		for body_data in bodies:
			map.add_body(Body.unserialize(body_data))
		# Parse actors
		var actors = sector_data["actors"]
		for actor_data in actors:
			var actor = Actor.new(actor_data["name"])
			actor.cooldown = actor_data["cooldown"]
			actor.draw_cooldown = actor_data["drawcooldown"]
			var hand = actor_data["hand"]
			for card in hand:
				actor.hand.append(Actor.Card.new(card))
			var deck = actor_data["deck"]
			for card in deck:
				actor.deck.append(Actor.Card.new(card))
			var ai_modules = actor_data["ai_modules"]
			for module in ai_modules:
				var ai = Node.new()
				ai.set_script(load("res://model/ai/" + module["name"] + ".gd"))
				ai.set_name(module["name"])
				ai.chance = module["chance"]
				actor.add_child(ai)
			map.add_actor(Identifiable.find(map.bodies, actor_data["body_id"]), actor)
	# Set current sector
	route.current_sector = route.find_sector(data["current_sector"])
	route.current_sector.show()
	# Store reference to player
	route.player = route.current_sector.get_node("actors").get_child(data["player_actor_id"])
	return route

func save_to_file(file):
	var data = {}
	data["sectors"] = []
	data["current_sector"] = current_sector.id
	# Group sectors into a single array
	var sectors = [current_sector]
	for sector in get_node("sectors").get_children():
		sectors.append(sector)
	var sectors_data = []
	var player_actor_id = -1
	data["sectors"] = sectors_data
	# Serialize sectors
	for sector in sectors:
		# Store sector general data
		var sector_data = {}
		sector_data["id"] = sector.id
		sector_data["width"] = sector.width
		sector_data["height"] = sector.height
		# Store floor tiles
		var floor_map = []
		for i in range(sector.height):
			for j in range(sector.width):
				floor_map.append(-1)
		var floors = sector.get_node("floors")
		for tile_pos in floors.get_used_cells():
			floor_map[tile_pos.x*sector.width + tile_pos.y] = floors.get_cellv(tile_pos)
		sector_data["floors"] = floor_map
		# Store wall tiles
		var wall_map = []
		for i in range(sector.height):
			for j in range(sector.width):
				wall_map.append(-1)
		var walls = sector.get_node("walls")
		for tile_pos in walls.get_used_cells():
			wall_map[tile_pos.x*sector.width + tile_pos.y] = walls.get_cellv(tile_pos)
		sector_data["walls"] = wall_map
		# Store bodies
		var bodies = []
		for body in sector.bodies:
			bodies.append(body.serialize())
		sector_data["bodies"] = bodies
		# Store actors
		var actors = []
		for actor in sector.actor_bodies:
			var actor_data = {}
			actor_data["name"] = actor.char_name
			actor_data["cooldown"] = actor.cooldown
			actor_data["drawcooldown"] = actor.draw_cooldown
			var hand_data = []
			for card in actor.hand:
				hand_data.append(card.name)
			actor_data["hand"] = hand_data
			var deck_data = []
			for card in actor.hand:
				deck_data.append(card.name)
			actor_data["deck"] = deck_data
			actor_data["body_id"] = sector.get_actor_body(actor).get_id()
			var ai_modules_data = []
			for module in actor.get_children():
				var module_data = {}
				module_data["name"] = module.get_name()
				module_data["chance"] = module.chance
				ai_modules_data.append(module_data)
			actor_data["ai_modules"] = ai_modules_data 
			actors.append(actor_data)
			if actor == player:
				player_actor_id = actors.size()-1
		sector_data["actors"] = actors
		sectors_data.append(sector_data)
	data["player_actor_id"] = player_actor_id
	file.store_string(data.to_json())

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
	get_node("sectors").add_child(current_sector)
	current_sector = find_sector(target)
	open_current_sector(player_body)

func close_current_sector():
	current_sector.set_fixed_process(false)
	current_sector.hide()
	current_sector.remove_actor(player)
	get_node("/root/sector").close()

func open_current_sector(player_body):
	var sector = get_node("/root/sector")
	get_node("sectors").remove_child(current_sector)
	sector.add_child(current_sector)
	sector.move_child(current_sector, 0)
	current_sector.set_name("map")
	current_sector.set_fixed_process(true)
	current_sector.show()
	# Set up camera
	current_sector.attach_camera(player)
	if player_body != null:
		current_sector.add_body(player_body)
		current_sector.add_actor(player_body, player)
		current_sector.move_actor(player, Vector2(0,0))
	sector.new_sector()

