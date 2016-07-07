
extends Node

var is_control = false

var actions

func _init():
  if self extends Control:
    is_control = true
    accep_event()
  else:
    set_process_unhandled_input(true)

func _input_event(event):
  if event.type == InputEvent.KEY:
    consume_input_key(event)

func _unhandled_input(event):
  _input_event(event)

func find_action(event):
  var index = 1
  var action = InputMap.get_action_from_id(index)

  while action != "":
    index += 1
    action = InputMap.get_action_from_id(index)
    if event.is_action(action):
      return action

func consume_input_key(event):
  var action_name = find_action(event)
  var method_name = "event_" + action_name.replace("ui_", "").replace("debug", "")

  print("calling method ", method_name, " action ", action_name)
  if not self.has_method(method_name):
    return

  self.call(method_name)

func event_cancel():
  get_node("/root/captains_log").finish()
  get_tree().quit()
