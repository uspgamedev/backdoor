
extends "res://components/controller/default_controller.gd"

export(String) var path = ".."

func consume_input_key(event):
  if event.type == InputEvent.KEY:
    getnode(path).hide()
