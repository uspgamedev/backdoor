
extends "res://game/core/backdoor_node.gd"

const TargetType = preload("res://game/database/cards/target_types.gd")

class CARD_ATTRIBUTE:
  const ATHLETICS = 0
  const ARCANE = 1
  const TECH = 2

export(String) var full_name = "Default Card"
export(String) var slug_name = "default-card"
export(int, "ATHLETICS", "ARCANE", "TECH") var attribute = 0
export(String, MULTILINE) var description = "a card"
export(int) var time_cost = 50
export(int, "NONE", "BODY_ONLY", "EMPTY_ONLY", "ANY") var target_type = TargetType.NONE
export(int) var target_range = 0

func get_full_name():
  return full_name

func get_time_cost():
  return time_cost

func get_attribute():
  return attribute

func can_be_evoked(actor):
  return true

func get_target_type():
  return target_type

func get_target_range():
  return target_range

func get_description():
  return description

func evoke(actor, target):
  assert(false)
