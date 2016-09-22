
extends "res://components/controller/default_controller.gd"

const COLOR_SELECTED = Color(234.0/255,166.0/255,81.0/255)
const COLOR_UNSELECTED = Color(1,1,1)

var choice
var choice_list_size
var cursor
var saves_node

onready var menu = get_parent()

func _ready():
  choice = 1 # default to new route choice
  self.disable()

func setup():
  saves_node = menu.saves_node
  cursor = saves_node.get_node("cursor")
  cursor.show()
  choice_list_size = saves_node.get_child_count() - 1
  self.enable()
  self.update_choice()

func update_choice():
  # updates cursor position
  # should play a sfx eventually too
  cursor.set_pos(Vector2(-32, ((choice-1) * 32) - 4))
  print(saves_node.get_child(choice))
  for btn in saves_node.get_children():
    if btn != cursor:
      if btn == saves_node.get_child(choice):
        btn.add_color_override("font_color", COLOR_SELECTED)
      else:
        btn.add_color_override("font_color", COLOR_UNSELECTED)

func event_up():
  choice = ((choice + choice_list_size - 2) % choice_list_size) + 1
  update_choice()

func event_down():
  choice = (choice % choice_list_size) + 1
  update_choice()

func event_select():
  var selection = saves_node.get_child(choice)
  assert(selection != cursor) # redundant check yay
  self.disable()
  cursor.hide()
  selection.emit_signal("selected")
