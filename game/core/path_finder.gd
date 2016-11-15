
extends Object

var tree

func _init(tree):
  self.tree = tree

func get_database():
  return self.tree.get_root().get_node("database")

func get_scene_manager():
  return get_database().get_node("scene_manager")

func get_current_route():
  return self.tree.get_root().get_node("Route")

func get_current_sector():
  return get_current_route().get_current_sector()

func get_route_view():
  return self.tree.get_root().get_node("RouteView")

func get_sector_view():
  return get_route_view().get_sector_view()
