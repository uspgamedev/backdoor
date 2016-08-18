

extends "res://model/cards/card_upgrade.gd"

func has_trigger_effect(kind):
  return kind == "damage_taken"

func trigger(actor, params):
  var source = params.source
  source.get_body().take_damage(DamageFormula.new().dice(2, 4), actor)
