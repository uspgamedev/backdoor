
extends Node

const Route = preload("res://scenes/route.gd")

func _init():
	print("captain's log created")

func _ready():
	print("captain's log ready")

func start():
	var file = File.new()
	file.open("res://out.save", File.READ)
	var route = Route.load_from_file(file)
	file.close()
	get_node("/root/sector").set_player(route.player)
	get_parent().call_deferred("add_child", route)

func finish():
	var file = File.new()
	file.open("res://out.save", File.WRITE)
	get_node("/root/route").save_to_file(file)
	file.close()
	get_tree().finish()
