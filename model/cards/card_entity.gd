
extends Node

class CARD_TYPE:
  const ARCANE = 0
  const ATHLETICS = 1
  const ENGINEERING = 2

export(int, "ARCANE", "ATHLETICS", "ENGINEERING") var card_type = 0
export(String) var description = "a card"
export(int) var time_cost = 50

func get_time_cost():
  return time_cost

func get_card_type():
  return card_type

func can_be_evoked(actor):
  return true

func get_options(actor):
  return []

func get_description():
  return description

func evoke(actor, options):
  print("Card evoked")
