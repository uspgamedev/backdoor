
extends "res://game/database/cards/components/effect.gd"

const DamageFormula = preload("res://game/core/formulas/damage.gd")

export(int) var base_damage = 0
export(int) var dice_count = 1
export(int) var dice_sides = 1

func execute(actor, card, target):
  var map = get_current_sector()
  var body = map.get_body_at(target)
  var formula = DamageFormula.new(self.base_damage, self.dice_count, \
                                  self.dice_sides, card.get_attribute())
  body.take_damage(formula.roll(actor), actor)
