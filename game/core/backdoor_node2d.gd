
extends Node

const PathFinder = preload("res://game/core/path_finder.gd")

onready var path_finder = PathFinder.new(get_tree())

func get_database():
  return path_finder.get_database()

func get_scene_manager():
  return path_finder.get_scene_manager()

func get_current_route():
  return path_finder.get_current_route()

func get_current_sector():
  return path_finder.get_current_sector()

func get_route_view():
  return path_finder.get_route_view()

func get_sector_view():
  return path_finder.get_sector_view()
