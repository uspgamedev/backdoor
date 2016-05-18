
extends "identifiable.gd"

var type
var pos
var hp
var damage

func _init(id, the_type, the_pos, the_hp).(id):
	type = the_type
	pos = the_pos
	hp = the_hp
	damage = 0

func take_damage(amount):
	damage += amount
	if is_dead():
		pass

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
	return body_data

static func unserialize(data):
	var body = new(data["id"], data["type"], Vector2(data["pos"][0], data["pos"][1]), data["hp"])
	body.damage = data["damage"]
	return body
