
extends Node2D

const Action   = preload("res://model/action.gd")

var player
var hand
var display_popup
var focuses_popup

onready var deck_view = get_node("HUD/deck")
onready var sector_view = get_node("SectorView")

func _init():
  print("sector created")

func _ready():
  #get_node("/root/database").start()
  print("sector ready")

func set_current_sector(sector):
  sector_view.load_sector(sector)
  sector_view.attach_camera(self.player)

func set_player(the_player):
  self.player = the_player
  get_node("HUD/UI_hook/CooldownBar").set_player(the_player)
  get_node("HUD/UI_hook/Hand").set_player(the_player)
  hand = get_node("HUD/UI_hook/Hand")
  deck_view.set_player(the_player)
  player.connect("equipped_item", get_node("HUD/base/item_stats"), "change_item")
  get_node("HUD/base").show()
  display_popup = get_node("HUD/CardDisplay")
  focuses_popup = get_node("HUD/FocussDisplay")
  get_node("HUD/Controller").set_player_map(player, hand)

func close():
  get_node("HUD/UI_hook/CooldownBar").stop()
  get_node("HUD/UI_hook/Hand").stop()
  get_node("HUD/base").hide()
  deck_view.stop()
  player.disconnect("equipped_item", get_node("HUD/base/item_stats"), "change_item")
  sector_view.unload_sector()
  set_process_input(false)

func new_sector():
  set_process_input(true)
  print("start sector")
