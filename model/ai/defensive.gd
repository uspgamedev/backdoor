
extends Node

const Action = preload("res://model/action.gd")

export(float, 0.0, 1.0, 0.01) var chance = 1

onready var actor = get_parent()

const moves = [
	Vector2(0,1),
	Vector2(1,0),
	Vector2(0,-1),
	Vector2(-1,0)
]

func think():
	for move in moves:
		var target = actor.get_body_pos() + move
		var body = get_node("/root/current/map").get_body_at(target)
		if body != null:
			actor.add_action(Action.MeleeAttack.new(target))
			break
	if !actor.has_action():
		actor.add_action(Action.Idle.new())
