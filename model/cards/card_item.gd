
extends "res://model/cards/card_entity.gd"

class SlotItem:
  const WEAPON = 0
  const SUIT = 1
  const ACCESSORY  = 2

export(int, "WEAPON", "SUIT", "ACCESSORY") var slot = 0
export(int) var initial_durability = 5

var consumption = 0

func get_initial_durability():
  return initial_durability

func get_durability():
  return initial_durability - consumption

func get_slot():
  return slot

func evoke(actor, options):
  actor.equip_item(self)

func consume_item():
  consumption += 1
