
extends "res://game/database/cards/components/card_base.gd"

const Effect = preload("res://game/database/cards/components/effect.gd")

onready var effects = get_children()

func _ready():
  for effect in effects:
    assert(effect.get_script() == Effect)

func evoke(actor, options):
  for effect in effects:
    effect.execute(actor, options)
