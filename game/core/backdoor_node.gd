
extends Node

func get_current_sector():
  return get_tree().get_root().get_node("Route").get_current_sector()
