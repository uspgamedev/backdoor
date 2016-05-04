
extends Node2D

const Route = preload("res://scenes/route.gd")

onready var saves_node = get_node("saves")

func _ready():
	var saves = get_node("/root/captains_log").get_profile()["saves"]
	for save in saves:
		var file = File.new()
		if file.open("user://" + save + ".save", File.READ) == 0:
			var char_name = Route.get_player_name_from_file(file)
			var button = Button.new()
			button.set_text(char_name)
			saves_node.add_child(button)
		else:
			print("Failed to load save file " + save)
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_node("/root/captains_log").finish()

func _on_new_game():
	pass
