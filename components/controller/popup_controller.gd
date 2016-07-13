
extends "res://components/controller/default_controller.gd"

export(String) var path = ".."

func consume_input_key(event):)
  if not enabled:
    return

  if event.type == InputEvent.KEY:
    get_node(path).hide()
    self.disable()
