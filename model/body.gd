
extends "identifiable.gd"

var type
var pos
var hp
var damage

var absorption = 0

signal damage_taken(amount, source)
signal moved(current_pos, new_pos)

func _init(id, the_type, the_pos, the_hp).(id):
  type = the_type
  pos = the_pos
  hp = the_hp
  damage = 0

func set_absorption(absorption):
  printt("Set dmg reduction")
  self.absorption = absorption

func get_absorption():
  return self.absorption

func take_damage(amount, source_actor):
  damage += max(amount - absorption, 0)
  printt("Damage done", amount, "reduction", absorption)
  if is_dead():
    pass
  emit_signal("damage_taken", amount, source_actor)

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
  body_data["absorption"] = absorption
  return body_data

static func unserialize(data):
  var body = new(data["id"], data["type"], Vector2(data["pos"][0], data["pos"][1]), data["hp"])
  body.damage = data["damage"]
  body.absorption = data["absorption"]
  return body
