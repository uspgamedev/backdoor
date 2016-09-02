
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
  self.update()

func update():
  # updates cursor position
  # should play a sfx eventually too
  cursor.set_pos(Vector2(-32, ((choice-1) * 32) - 4))
  print(saves_node.get_child(choice))
  for btn in saves_node.get_children():
    if btn != cursor:
      if btn == saves_node.get_child(choice):
        print(str(choice) + " is changing color!")
        btn.add_color_override("font_color", Color(234.0/255,166.0/255,81.0/255))
      else:
        btn.add_color_override("font_color", Color(1,1,1))



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
