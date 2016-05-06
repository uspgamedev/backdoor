
extends Node2D

const MenuButton = preload("res://scenes/ui/button.xscn")

const Route = preload("res://scenes/route.gd")

onready var saves_node = get_node("saves")
onready var caplog = get_node("/root/captains_log")

func _ready():
	var saves = caplog.get_profile()["saves"]
	for save in saves:
		var file = File.new()
		if file.open("user://" + caplog.route_id(save) + ".save", File.READ) == 0:
			var char_name = Route.get_player_name_from_file(file)
			var button = MenuButton.instance()
			button.set_text(char_name)
			button.connect("pressed", self, "_on_load_game", [save])
			saves_node.add_child(button)
		else:
			print("Failed to load save file " + caplog.route_id(save))
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_node("/root/captains_log").finish()

func _on_new_game():
	get_node("/root/captains_log").create_route()
	hide()

func _on_load_game(save):
	get_node("/root/captains_log").load_route(save)
	hide()
	get_tree().set_current_scene(get_node("/root/sector"))
