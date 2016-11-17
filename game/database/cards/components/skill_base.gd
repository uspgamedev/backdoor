
extends "res://game/database/cards/components/card_base.gd"

const Step = preload("res://game/database/cards/components/step.gd")

onready var steps = get_children()

func _ready():
  for step in steps:
    assert(step extends Step)

func evoke(actor, target):
  for step in steps:
    step.execute(actor, self, target)
