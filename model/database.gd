
extends Node

const RouteScene = preload("res://model/route.tscn")

const Route = preload("res://model/route.gd")
const Actor = preload("res://model/actor.gd")
const Body = preload("res://model/body.gd")

onready var loading = get_node("/root/loading")
onready var map_generator = get_node("map_generator")
onready var profile = get_node("profile")

func get_profile():
  return profile

func erase_route(id):
  profile.erase_journal(id)

func create_route():
  var route = RouteScene.instance()
  route.id = profile.find_free_route_id()
  profile.add_journal(route.id)
  var w = 64
  var h = 64
  var map_node = map_generator.generate_map(1,w,h)
  #route.get_node("sectors").add_child(map_node)
  route.current_sector = map_node
  map_node.show()
  var player = Actor.new("hero")
  var cards_db = get_node("cards")
  for i in range(20):
    var aux = i % cards_db.get_child_count()
    var card = Actor.Card.new(cards_db.get_child(aux))
    player.deck.append(card)
  route.player = player
  #get_node("/root/sector").set_player(player)
  var player_body = Body.new(1, "hero", map_node.get_random_free_pos(), 10)
  map_node.add_body(player_body)
  map_node.add_actor(player_body, player)
  do_save_route(route, player)
  load_route(route.id)
  #get_parent().add_child(route)
  #loading.end()

func load_route(id):
  var file = profile.get_journal_file_reader(id)
  assert(file != null)
  var data = {}
  data.parse_json(file.get_as_text())
  var route = Route.unserialize(data, self)
  file.close()
  get_node("/root/sector").set_player(route.player)
  get_parent().call_deferred("add_child", route)
  loading.end()

func save_route():
  var route = get_node("/root/route")
  do_save_route(route, route.player)

func do_save_route(route, player):
  var file = profile.get_journal_file_writer(route.id)
  assert(file != null)
  file.store_string(route.serialize(self, player).to_json())
  file.close()

func finish():
  if get_node("/root/").has_node("route"):
    save_route()
  profile.save()
  get_tree().quit()
