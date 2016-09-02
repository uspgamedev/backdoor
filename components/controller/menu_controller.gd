
extends "res://components/controller/default_controller.gd"

var choice = 1
var choice_list_size
var cursor
var saves_node


func setup():
  saves_node = get_parent().saves_node
  cursor = saves_node.get_node("cursor")
  choice_list_size = saves_node.get_child_count() - 1
  self.connect("new_game", get_parent(), "_on_new_game")

func update():
  # updates cursor position
  # should play a sfx eventually too
  cursor.set_pos(Vector2(-32, -24 + choice * 16))
  print(saves_node.get_child(choice))

func event_up():
  choice = choice - 1
  if choice < 1: choice = choice_list_size
  update()

func event_down():
  choice = (choice % choice_list_size) + 1
  update()

func event_select():
  var selection = saves_node.get_child(choice)
  if saves_node.get_child(choice).get_type() != "Sprite":
    if selection.get("route_id"):
      selection.emit_signal("pressed", selection.route_id)
    else:
      selection.emit_signal("pressed")
    self.disable()
