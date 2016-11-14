
extends Node

func get_current_route():
  return get_tree().get_root().get_node("Route")

func get_current_sector():
  return get_current_route().get_current_sector()

func get_route_view():
  return get_tree().get_root().get_node("RouteView")
