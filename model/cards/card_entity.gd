
extends "res://game/core/backdoor_node.gd"

const DamageFormula = preload("res://components/util/damage_formula.gd")

class CARD_ATTRIBUTE:
  const ATHLETICS = 0
  const ARCANE = 1
  const TECH = 2

export(int, "ATHLETICS", "ARCANE", "TECH") var card_attribute = 0
export(String, MULTILINE) var description = "a card"
export(int) var time_cost = 50

func get_time_cost():
  return time_cost

func get_card_attribute():
  return card_attribute

func can_be_evoked(actor):
  return true

func get_options(actor):
  return []

func get_description():
  return description

func evoke(actor, options):
  print("Card evoked")

## Utility functions

func dist(actor, target):
  var d = target - actor.get_body_pos()
  return abs(d.x) + abs(d.y)
