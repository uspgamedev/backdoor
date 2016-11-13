
extends Control

const MenuButton = preload("res://components/ui/save-button.tscn")

const Route = preload("res://game/route/route.gd")

onready var loading = get_node("/root/loading")
onready var transition = get_node("/root/transition")
onready var saves_node = get_node("saves")
onready var controller = get_node("controller")
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
  show()
  transition.connect("end_fadein", controller, "setup", [], CONNECT_ONESHOT)
  transition.unfade_from_black(.5)

func stop():
  hide()
  loading.start()
  for button in saves_node.get_children():
    if button.get_name() != "new_game" and button.get_name() != "cursor":
      button.queue_free()

func transition_out(database_action, file):
  transition.connect("end_fadeout", self, "stop", [], CONNECT_ONESHOT)
  transition.connect("end_fadeout", transition, "unfade_from_black", [.5], CONNECT_ONESHOT)
  if not file:
    transition.connect("end_fadein", database, database_action, [], CONNECT_ONESHOT)
  else:
    transition.connect("end_fadein", database, database_action, [file], CONNECT_ONESHOT)
  transition.fade_to_black(.5)

func _on_new_game_selected():
  print("new game selected!")
  transition_out("create_route", false)

func _on_load_game_selected(save_id):
  print("load game selected!")
  transition_out("load_route", save_id)
  get_tree().set_current_scene(get_node("/root/sector"))
