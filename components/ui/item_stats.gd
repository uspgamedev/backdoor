
extends Control

const ItemCard = preload("res://model/cards/card_item.gd")

onready var slots = [
  get_node("weapon"),
  get_node("suit"),
  get_node("accessory")
]

func change_item(item):
  var slot = slots[item.get_slot()]
  print("change item=", item)
  slot.set_text(slot.get_name() + ": " + item.get_name())
