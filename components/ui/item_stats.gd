
extends Control

const ItemCard = preload("res://model/cards/card_item.gd")

onready var slots = [
  get_node("weapon"),
  get_node("suit"),
  get_node("accessory")
]

func change_item(item, slot):
  var item_name = "none"
  if item != null:
    item_name = item.get_name()
  var slot_item = slots[slot]
  slot_item.set_text(slot_item.get_name() + ": " + item_name)
  printt("##################### change item")
