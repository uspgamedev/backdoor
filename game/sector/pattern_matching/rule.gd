
extends "res://game/core/backdoor_node.gd"

const Tiles = preload("res://game/sector/tiles.gd")

export(int) var result = Tiles.EMPTY

onready var patterns = get_children()

func match(map_reader, i, j):
  for pattern in patterns:
    if pattern.match(map_reader, i, j):
      return result
  return null
