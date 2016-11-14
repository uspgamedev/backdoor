
extends Node

const Tiles         = preload("res://game/sector/tiles.gd")
const Actor         = preload("res://model/actor.gd")
const Body          = preload("res://model/body.gd")
const Identifiable  = preload("res://model/identifiable.gd")

# Default
var map
var bodies
var actor_bodies

# Assigned
var id
var width
var height
var tiles

onready var actors = get_node("Actors")

signal body_added(body)
signal body_removed(body)
signal actor_added(body, actor)
signal actor_removed(body, actor)

func _init():
  map = []
  bodies = []
  actor_bodies = {}

func pvt_setup(id, width, height):
  self.width = int(width)
  self.height = int(height)
  self.id = id
  self.tiles = []
  self.map.resize(width * height)
  for i in range(width):
    for j in range(height):
      self.tiles.push_back(Vector2(i,j))

func pvt_copy_tiles(data):
  for j in range(data.size()):
    map[j] = data[j]

func get_tile(i, j):
  return map[i * width + j]

func get_tile_v(tile):
  return get_tile(tile.x, tile.y)

func get_tiles():
  return tiles

func is_empty_space(pos):
  return Tiles.is_floor(get_tile_v(pos))

func find_free_body_id():
  var id = 1
  while Body.find(bodies, id):
    id += 1
  return id

func get_random_free_pos():
  var pos = Vector2(1 + randi()%(width-2), 1+ randi()%(height-2))
  while !is_empty_space(pos):
    pos = Vector2(1 + randi()%(width-2), 1 + randi()%(height-2))
  return pos

func get_bodies():
  return bodies

func add_body(body):
  bodies.append(body)
  emit_signal("body_added", body)

func remove_body(body):
  bodies.erase(body)
  emit_signal("body_removed", body)

func add_actor(body, actor):
  actors.add_child(actor)
  actor_bodies[actor] = body
  emit_signal("actor_added", body, actor)

func get_actor(id):
  return actors.get_child(id)

func get_actors():
  return actors.get_children()

func remove_actor(actor):
  var body = actor_bodies[actor]
  if body != null:
    actor_bodies.erase(actor)
    emit_signal("actor_removed", body, actor)
    remove_body(body)
  actors.remove_child(actor)

func move_actor(actor, new_pos):
  move_body(actor_bodies[actor], new_pos)

func move_body(body, new_pos):
  var old_pos = body.pos
  body.pos = new_pos
  body.emit_signal("moved", old_pos, new_pos)

func get_actor_body(actor):
  assert(actor_bodies.has(actor))
  return actor_bodies[actor]

func get_body_actor(body):
  for actor in actor_bodies:
    if actor_bodies[actor] == body:
      return actor

func get_body_at(pos):
  for body in bodies:
    if body.pos == pos:
      return body
  return null

# FIXME
func check_dead_bodies():
  for body in bodies:
    if body.is_dead():
      var actor = get_body_actor(body)
      if actor == get_parent().get_parent().player: #FIXME
        get_node("/root/database/scene_manager").call_deferred("destroy_route")
      else:
        remove_actor(actor)

func serialize(db):
  # Store sector general data
  var sector_data = {}
  sector_data["id"] = id
  sector_data["width"] = width
  sector_data["height"] = height
  # Store floor tiles
  var tiles_data = []
  for i in range(height):
    for j in range(width):
      tiles_data.append(-1)
  for tile in get_tiles():
    tiles_data[tile.x*width + tile.y] = get_tile_v(tile)
  sector_data["tiles"] = tiles_data
  # Store bodies
  var bodies = []
  for body in get_bodies():
    bodies.append(body.serialize())
  sector_data["bodies"] = bodies
  # Store actors
  var actors = []
  for actor in actor_bodies:
    actors.append(actor.serialize(db))
  sector_data["actors"] = actors
  return sector_data

func unserialize(data, db):
  # Parse sector
  pvt_setup(data["id"], data["width"], data["height"])
  # General sector info
  # Parse sector map
  pvt_copy_tiles(data["tiles"])
  # Parse bodies
  var bodies = data["bodies"]
  for body_data in bodies:
    add_body(Body.unserialize(body_data))
  # Parse actors
  var actors = data["actors"]
  for actor_data in actors:
    var actor = Actor.unserialize(actor_data, db)
    add_actor(Identifiable.find(get_bodies(), actor_data["body_id"]), actor)
