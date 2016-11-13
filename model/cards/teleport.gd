
extends "res://model/cards/card_skill.gd"

func valid_target(actor, target):
  var map = get_node("/root/Route").get_current_sector()
  return dist(actor,target) <= 10 and map.is_empty_space(target) and map.get_body_at(target) == null

func can_be_evoked(actor):
  return true

func get_options(actor):
  return [
    { "type": "TARGET", "check": funcref(self, "valid_target"), "aoe":null }
  ]

func evoke(actor, options):
  var target = options[0]
  get_node("/root/Route").get_current_sector().move_body(actor.get_body(), target)
