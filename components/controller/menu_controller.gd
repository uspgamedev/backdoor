
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
  self.enable()

func update():
  # updates cursor position
  # should play a sfx eventually too
  print(choice)
  cursor.set_pos(Vector2(-32, ((choice-1) * 28) - 4))
  print(cursor.get_pos())
  print(saves_node.get_child(choice))

func event_up():
  choice = ((choice + choice_list_size - 2) % choice_list_size) + 1
  update()

func event_down():
  choice = (choice % choice_list_size) + 1
  update()

func event_select():
  var selection = saves_node.get_child(choice)
  if saves_node.get_child(choice) != cursor:
    if selection.get("route_id"):
      selection.emit_signal("pressed", selection.route_id)
    else:
      selection.emit_signal("pressed")
    self.disable()
  else:
    print("Error! This shouldn't happen! You can't select the cursor to load!")
