
extends "res://game/database/cards/components/step.gd"

const Effect = preload("res://game/database/cards/components/effect.gd")

onready var effects = get_children()

func _ready():
  for effect in effects:
    assert(effect extends Effect)

func execute(actor, card, target):
  for effect in effects:
    effect.execute(actor, card, target)
