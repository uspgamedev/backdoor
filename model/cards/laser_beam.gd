
extends "res://model/cards/card_skill.gd"

const AREA = [[1,1,1,1,1]]
const CENTER = Vector2(0,0)
const RANGE = 5

func valid_target(actor, target):
  var map = get_node("/root/sector/map")
  return map.is_empty_space(target)

func get_area(pos, target):
  if pos.x == target.x:
    return [[1,1,1,1,1]]

func get_options(actor):
  return [
    { "type": "TARGET", "check": funcref(self, "valid_target"),
    "aoe":{"format":AREA, "center":CENTER}}
  ]

func evoke(actor, options):
  var map = get_node("/root/sector/map")
  var pos = options[0]
  for i in range(AREA.size()):
    for j in range(AREA[i].size()):
      var target = AREA[i][j]
      if target == 1:
        var body = map.get_body_at(pos - CENTER + Vector2(j,i))
        if body != null:
          printt("LASERBEAM SHOT", i, j)
          body.take_damage(20)
