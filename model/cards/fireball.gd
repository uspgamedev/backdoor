
extends "res://model/cards/card_skill.gd"

const AREA = [[0,1,0],
              [1,1,1],
              [0,1,0]]
const CENTER = Vector2(1,1)

func valid_target(actor, target):
  var map = get_node("/root/sector/map")
  return map.is_empty_space(target)

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
        printt("FIREBALL HIT", i, j)
        if body != null:
          body.take_damage(20, actor)
