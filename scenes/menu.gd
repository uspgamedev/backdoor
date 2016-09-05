
extends Control

const MenuButton = preload("res://components/ui/save-button.tscn")

const Route = preload("res://model/route.gd")

onready var loading = get_node("/root/loading")
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
    button.connect("selected", self, "_on_load_game_selected", [route_id])
    saves_node.add_child(button)
  get_node("Controller").setup()
  set_process_input(true)
  show()

func stop():
  hide()
  loading.start()
  for button in saves_node.get_children():
    if button.get_name() != "new_game" and button.get_name() != "cursor":
      button.queue_free()
  set_process_input(false)

func _on_new_game_selected():
  print("new game selected!")
  stop()
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  database.create_route()

func _on_load_game_selected(save_id):
  print("load game selected!")
  stop()
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  database.load_route(save_id)
  get_tree().set_current_scene(get_node("/root/sector"))
