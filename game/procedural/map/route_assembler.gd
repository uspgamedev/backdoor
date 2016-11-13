
const Tiles = preload("res://game/sector/tiles.gd")

const Actor = preload("res://model/actor.gd")

var route_data_
var current_sector_
var current_body_
var current_actor_

var next_sector_id_ = 0
var next_body_id_ = 0
var next_actor_id_ = 0

func _init(id):
  route_data_ = {}
  route_data_.id = id
  route_data_.sectors = []
  route_data_.player_actor_id = -1
  route_data_.current_sector = -1

func get_route_data():
  return route_data_

func new_sector():
  current_sector_ = {}
  current_sector_.id = next_sector_id_
  next_sector_id_ += 1
  current_sector_.bodies = []
  current_sector_.actors = []
  route_data_.sectors.append(current_sector_)

func set_sector_map(tiles, width, height):
  current_sector_.width = width
  current_sector_.height = height
  current_sector_.tiles = tiles

func new_body(type, hp, absorption, pos):
  current_body_ = {}
  current_body_.id = next_body_id_
  next_body_id_ += 1
  current_body_.type = type
  current_body_.damage = 0
  current_body_.hp = hp
  current_body_.absorption = absorption
  if pos != null:
    current_body_.pos = [pos.x, pos.y]
  else:
    ## random empty position
    var width = current_sector_.width
    var height = current_sector_.height
    var tiles = current_sector_.tiles
    var pos = Vector2(1 + randi()%(width-2), 1+ randi()%(height-2))
    while Tiles.is_floor(tiles[pos.x*width + pos.y]):
      pos = Vector2(1 + randi()%(width-2), 1 + randi()%(height-2))
    current_body_.pos = pos
  current_sector_.bodies.append(current_body_)

func new_actor(name, speed):
  current_actor_ = {}
  current_actor_.id = next_actor_id_
  next_actor_id_ += 1
  current_actor_.name = name
  current_actor_.drawcooldown = Actor.DRAW_TIME
  current_actor_.cooldown = Actor.BASE_COOLDOWN/speed
  current_actor_.speed = speed
  current_actor_.body_id = current_body_.id
  current_actor_.hand = []
  current_actor_.deck = []
  current_actor_.focuses = []
  current_actor_.ai_modules = []
  current_sector_.actors.append(current_actor_)

func add_to_actor_deck(card_id):
  current_actor_.deck.append(card_id)

func make_sector_current():
  route_data_.current_sector = current_sector_.id

func make_actor_player():
  route_data_.player_actor_id = current_actor_.id
