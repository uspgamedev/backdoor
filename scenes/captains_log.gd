
extends Node

const Route = preload("res://scenes/route.gd")

var profile_data = {}

func _init():
	var profile = File.new()
	if profile.open("user://profile.meta", File.READ) == 0:
		profile_data.parse_json(profile.get_as_text())
		profile.close()
	else:
		profile_data["saves"] = []
	print("captain's log created")

func get_profile():
	return profile_data

func _ready():
	print("captain's log ready")

func start():
	var file = File.new()
	file.open("res://save2.save", File.READ)
	var route = Route.load_from_file("0001", file)
	file.close()
	#get_node("/root/sector").set_player(route.player)
	#get_parent().call_deferred("add_child", route)
	pass

func finish():
	var file = File.new()
	if get_node("/root/").has_node("route"):
		var route = get_node("/root/route")
		file.open("user://" + route.id + ".save", File.WRITE)
		route.get_node("/root/route").save_to_file(file)
		file.close()
	file.open("user://profile.meta", File.WRITE)
	file.store_string(profile_data.to_json())
	file.close()
	get_tree().finish()
