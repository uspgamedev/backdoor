
extends "identifiable.gd"

var type
var pos
var hp
var damage

var damage_reduction = 0

signal damage_taken()

func _init(id, the_type, the_pos, the_hp).(id):
  type = the_type
  pos = the_pos
  hp = the_hp
  damage = 0

func set_damage_reduction(damage_reduction):
  printt("Set dmg reduction")
  self.damage_reduction = damage_reduction

func get_damage_reduction():
  return self.damage_reduction

func take_damage(amount):
  damage += max(amount - damage_reduction, 0)
  printt("Damage done", amount, "reduction", damage_reduction)
  if is_dead():
    pass
  emit_signal("damage_taken")

func heal(amount):
  damage = max(damage - amount, 0)

func get_hp_percent():
  return 100*(hp - damage)/hp

func is_dead():
  return damage >= hp

func serialize():
  var body_data = {}
  body_data["id"] = get_id()
  body_data["type"] = type
  body_data["pos"] = [pos.x, pos.y]
  body_data["hp"] = hp
  body_data["damage"] = damage
  body_data["damage_reduction"] = damage_reduction
  return body_data

static func unserialize(data):
  var body = new(data["id"], data["type"], Vector2(data["pos"][0], data["pos"][1]), data["hp"])
  body.damage = data["damage"]
  body.damage_reduction = data["damage_reduction"]
  return body
