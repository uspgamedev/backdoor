
extends "res://model/cards/card_entity.gd"

export(int)     var bonus_amount  = 2
export(String)  var static_kind   = "none"
export(int)     var static_value  = 0

class StaticEffect:
  var kind_
  var value_
  func _init(kind, value):
    kind_ = kind
    value_ = value
  func get_kind():
    return kind_
  func get_value():
    return value_

func get_bonus_amount():
  return bonus_amount

func has_static_effect(kind):
  return static_kind == kind

func get_static_effect():
  return static_value

func evoke(actor, options):
  actor.set_upgrade(self)
