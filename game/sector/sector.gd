
extends Node

const Tiles         = preload("res://game/sector/tiles.gd")
const Actor         = preload("res://model/actor.gd")
const Body          = preload("res://model/body.gd")
const Identifiable  = preload("res://model/identifiable.gd")

var id
var width
var height
var map
var bodies
var actor_bodies

signal body_added(body)
signal body_removed(body)
signal actor_added(body, actor)
signal actor_removed(body, actor)

func _init():
  bodies = []
  actor_bodies = {}

func is_empty_space(pos):
  return Tiles.is_floor(map[pos.x, pos.y])

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

func add_body(body):
  bodies.append(body)
  emit_signal("body_added", body)

func remove_body(body):
  bodies.erase(body)
  emit_signal("body_removed", body)

func add_actor(body, actor):
  actor_bodies[actor] = body
  emit_signal("actor_added", body, actor)

func remove_actor(actor):
  var body = actor_bodies[actor]
  if body != null:
    actor_bodies.erase(actor)
    emit_signal("actor_removed", body, actor)
    remove_body(body)

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
      if actor == get_parent().player:
        get_node("/root/database/scene_manager").call_deferred("destroy_route")
      else:
        remove_actor(actor)
