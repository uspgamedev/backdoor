
extends Node

var next = 0

func _ready():
  pass

func generate_id():
  next += 1
  return next
