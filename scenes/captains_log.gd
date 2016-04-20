
extends Node

const Route = preload("res://scenes/route.gd")

func _init():
	print("captain's log created")

func _ready():
	print("captain's log ready")

func start():
	var route = Route.load_from_file(null)
	get_parent().call_deferred("add_child", route)
