
extends Node

# Scenes
const SectorScene   = preload("res://game/sector/sector.tscn")

# Classes
const Identifiable  = preload("res://model/identifiable.gd")
const Body          = preload("res://model/body.gd")
const Actor         = preload("res://model/actor.gd")
const Sector        = preload("res://game/sector/sector.gd")

var current_sector
var player
var id

var done
var next_sector

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

func unserialize(data, db):
  self.id = data.id
  var sectors = data["sectors"]
  for sector_data in sectors:
    var sector = SectorScene.instance()
    self.get_node("sectors").add_child(sector)
    sector.unserialize(sector_data, db)
  # Set current sector
  self.current_sector = self.find_sector(data["current_sector"])
  # Store reference to player
  self.player = self.current_sector.get_actor(data["player_actor_id"])

func serialize(db, player):
  var data = {}
  data.id = id
  data["sectors"] = []
  data["current_sector"] = current_sector.id
  # Group sectors into a single array
  var sectors = [current_sector]
  for sector in get_node("sectors").get_children():
    print("KOTOARISHIMASU")
    sectors.append(sector)
  var sectors_data = []
  var player_actor_id = -1
  data["sectors"] = sectors_data
  # Serialize sectors
  for sector in sectors:
    var sector_data = sector.serialize(db)
    sectors_data.append(sector_data)
    var i = 0
    for actor_data in sector_data["actors"]:
      if actor_data["name"] == player.char_name:
        player_actor_id = i
        break
      i += 1
  data["player_actor_id"] = player_actor_id
  return data

func _ready():
  pass

func get_current_sector():
  return current_sector

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
  var route_view = get_node("/root/RouteView")
  route_view.set_current_sector(self.current_sector)
  # FIXME (change_sector)
  #if player_body != null:
  #  current_sector.add_body(player_body)
  #  current_sector.add_actor(player_body, player)
  #  current_sector.move_actor(player, Vector2(0,0))
  route_view.new_sector()
  set_fixed_process(true)
  self.done = false
  self.next_sector = null
  manage_actors()

func set_next_sector(target):
  done = true
  next_sector = target

func _fixed_process(delta):
  for actor in current_sector.get_actors():
    if actor != player and !actor.has_action() and actor.is_ready():
      actor.pick_ai_module().think()

func manage_actors():
  while not done:
    for actor in current_sector.actor_bodies:
      if current_sector.get_actor_body(actor).is_dead():
        continue
      actor.step_time()
      if actor.is_ready():
        if !actor.has_action():
          yield(actor, "has_action")
        actor.use_action()
    current_sector.check_dead_bodies()
    yield(get_tree(), "fixed_frame" )
  if next_sector != null:
    get_node("/root/Route").change_sector(next_sector)
