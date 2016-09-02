
extends Control

const MenuButton = preload("res://components/ui/save-button.tscn")

const Route = preload("res://model/route.gd")

onready var saves_node = get_node("saves")
onready var database = get_node("/root/database")
onready var profile = database.get_profile()

func _ready():
  start()

func start():
  var journals = profile.get_journals()
  for route_id in journals:
    var char_name = profile.get_player_name(route_id)
    var button = MenuButton.instance()
    button.set_text(char_name)
    button.set("route_id", route_id)
    #button.connect("pressed", self, "_on_load_game", [route_id])
    button.connect("selected", self, "_on_load_game_selected", [route_id])
    saves_node.add_child(button)
  get_node("Controller").setup()
  set_process_input(true)
  show()

func stop():
  for button in saves_node.get_children():
    if button.get_name() != "new_game" and button.get_name() != "cursor":
      button.queue_free()
  set_process_input(false)
  hide()

func _on_new_game_selected():
  print("new game selected!")
  database.create_route()
  stop()

func _on_load_game_selected(save_id):
  print("load game selected!")
  stop()
  database.load_route(save_id)
  get_tree().set_current_scene(get_node("/root/sector"))
