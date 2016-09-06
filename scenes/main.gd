
extends Node2D

const Action   = preload("res://model/action.gd")

var player
var map
var done
var next_sector
var hand
var display_popup
var upgrades_popup

onready var deck_view = get_node("HUD/deck")

func _init():
  print("sector created")

func _ready():
  #get_node("/root/database").start()
  print("sector ready")

func set_player(the_player):
  player = the_player
  get_node("HUD/UI_hook/CooldownBar").set_player(the_player)
  get_node("HUD/UI_hook/Hand").set_player(the_player)
  hand = get_node("HUD/UI_hook/Hand")
  deck_view.set_player(the_player)
  player.connect("equipped_item", get_node("HUD/base/item_stats"), "change_item")
  get_node("HUD/base").show()
  display_popup = get_node("HUD/CardDisplay")
  upgrades_popup = get_node("HUD/UpgradesDisplay")
  get_node("HUD/Controller").set_player_map(player, hand)

func close():
  get_node("HUD/UI_hook/CooldownBar").stop()
  get_node("HUD/UI_hook/Hand").stop()
  get_node("HUD/base").hide()
  deck_view.stop()
  player.disconnect("equipped_item", get_node("HUD/base/item_stats"), "change_item")
  set_fixed_process(false)
  set_process_input(false)
  map.queue_free()
  done = true
  map = null

func new_sector():
  map = get_node("map")
  set_fixed_process(true)
  set_process_input(true)
  print("start sector")
  done = false
  next_sector = null
  manage_actors()

func set_next_sector(target):
  done = true
  next_sector = target

func manage_actors():
  while not done:
    for actor in map.actor_bodies:
      if map.get_actor_body(actor).is_dead():
        continue
      actor.step_time()
      if actor.is_ready():
        if !actor.has_action():
          yield(actor, "has_action")
        actor.use_action()
    map.check_dead_bodies()
    yield(get_tree(), "fixed_frame" )
  if next_sector != null:
    get_node("/root/route").change_sector(next_sector)

func _fixed_process(delta):
  for actor in map.actor_bodies:
    if actor != player and !actor.has_action() and actor.is_ready():
      actor.pick_ai_module().think()
