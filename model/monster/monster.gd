
extends Node

const Body = preload("res://model/body.gd")
const Actor = preload("res://model/actor.gd")
const Wander = preload("res://model/ai/wander.gd")

export var body_hp = 10
export(String) var body_type = "dummy"
onready var ai_modules = get_node("ai_modules").get_children()

func _ready():
  for card in get_node("cards").get_children():
    print(card.get_name())

func create(map, pos):
  var body = Body.new(map.find_free_body_id(), body_type, pos, body_hp)
  var actor = Actor.new(get_name())
  #for module in ai_modules:
  #  var ai = module.duplicate()
  #  actor.add_child(ai)
  ### FIXME #61
  var wander = Node.new()
  wander.set_script(Wander)
  actor.add_child(wander)
  ###
  map.add_body(body)
  map.add_actor(body, actor)
