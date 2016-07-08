
extends Node

var enabled = true
var actions = {}

func _init():
  if self extends Control:
    set_process_input(true)
  else:
    set_process_unhandled_input(true)
  build_action_dict()

func enable():
  #print("enable ", get_path())
  enabled = true

func disable():
  #print("disable ", get_path())
  enabled = false

func _input_event(event):
  if event.is_pressed() and event.type == InputEvent.KEY:
    consume_input_key(event)

func _input(event):
  _input_event(event)

func _unhandled_input(event):
  _input_event(event)

func get_event_name(action):
  return "event_" + action.replace("ui_", "").replace("debug_", "")

func build_action_dict():
  var index = 1
  var action = InputMap.get_action_from_id(index)

  while action != "":
    index += 1
    action = InputMap.get_action_from_id(index)
    var method_name = get_event_name(action)
    if self.has_method(method_name):
      actions[action] = funcref(self, method_name)

func consume_input_key(event):
  if not enabled:
    return

  for action in actions.keys():
    if event.is_action_pressed(action):
      #print("calling method ", get_event_name(action), " action ", action)
      actions[action].call_func()
      return

func event_cancel():
  get_node("/root/captains_log").finish()
  get_tree().quit()
