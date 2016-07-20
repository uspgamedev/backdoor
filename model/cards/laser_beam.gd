
extends "res://model/cards/card_skill.gd"

const RANGE = 5

var horizontal = true

func valid_target(actor, target):
  var map = get_node("/root/sector/map")
  var pos = actor.get_body_pos()
  return map.is_empty_space(target) and \
    (pos.x == target.x and pos.y != target.y and abs(pos.y - target.y) < RANGE) or \
    (pos.y == target.y and pos.x != target.x and abs(pos.x - target.x) < RANGE)

func get_area(actor, target):
  if actor.get_body_pos().x == target.x:
    horizontal = true
    return [[1],[1],[1],[1]]
  else:
    horizontal = false
    return [[1,1,1,1]]

func get_center(actor, target):
  var dist
  var pos = actor.get_body_pos()
  if horizontal:
    dist = target.y - pos.y
    if dist < 0:
      dist = RANGE + dist
    return Vector2(0, dist - 1)
  else:
    dist = target.x - pos.x
    if dist < 0:
      dist = RANGE + dist
    return Vector2(dist - 1, 0)

func get_options(actor):
  return [
    { "type": "TARGET", "check": funcref(self, "valid_target"),
    "aoe":{"format": funcref(self, "get_area"), "center":funcref(self, "get_center")}}
  ]

func evoke(actor, options):
  var map = get_node("/root/sector/map")
  var pos = options[0]
  var area = get_area(actor.get_body_pos(), pos)
  for i in range(area.size()):
    for j in range(area[i].size()):
      var target = area[i][j]
      if target == 1:
        var body = map.get_body_at(pos - CENTER + Vector2(j,i))
        if body != null:
          printt("LASERBEAM SHOT", i, j)
          body.take_damage(15)
