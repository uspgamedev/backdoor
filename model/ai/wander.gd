
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

func _ready():
  print("HAHAHAHA")

func think():
  var move = moves[randi()%moves.size()]
  actor.add_action(Action.Move.new(actor.get_body_pos() + move))
  if !actor.has_action():
    actor.add_action(Action.Idle.new())
