
extends Node

var profile_data

func _init():
	profile_data = {}
	var profile_stream = File.new()
	if profile_stream.open("user://profile.meta", File.READ) == 0:
		profile_data.parse_json(profile_stream.get_as_text())
		profile_stream.close()
	else:
		profile_data["saves"] = []

func get_journal_filename(route_id):
	return "user://route-" + var2str(int(route_id)) + ".journal"

func get_journal_file_reader(route_id):
	var file = File.new()
	var filename = get_journal_filename(route_id)
	if file.open(filename, File.READ) == 0:
		return file
	else:
		print("Could not open journal '", filename,"': ", file.get_error())

func get_journal_file_writer(route_id):
	var file = File.new()
	var filename = get_journal_filename(route_id)
	if file.open(filename, File.WRITE) == 0:
		return file
	else:
		print("Could not open journal '", filename,"': ", file.get_error())

func get_player_name(route_id):
	var file = get_journal_file_reader(route_id)
	assert(file != null)
	var data = {}
	var text = file.get_as_text()
	data.parse_json(text)
	file.close()
	var sector_data
	for sector in data["sectors"]:
		if sector["id"] == data["current_sector"]:
			sector_data = sector
	return sector_data["actors"][int(data["player_actor_id"])]["name"]
