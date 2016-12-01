
extends Node

class FILE_TYPE:
  const VERSION=false
  const JOURNAL=true

onready var meta = get_node("/root/database/Meta")

var profile_data

func _init():
  profile_data = {}
  var profile_stream = File.new()
  if profile_stream.open("user://profile.meta", File.READ) == OK:
    profile_data.parse_json(profile_stream.get_as_text())
    profile_stream.close()
  else:
    profile_data["saves"] = []

func find_free_route_id():
  var id = 1
  for route_id in profile_data["saves"]:
    if route_id != id:
      break
    id += 1
  return id

func get_journal_filename(route_id, type =  FILE_TYPE.JOURNAL):
  if type == FILE_TYPE.JOURNAL:
    return "user://route-" + var2str(int(route_id)) + ".journal"
  return "user://route-" + var2str(int(route_id)) + ".version"

func check_journal_version(route_id):
  var v_file = File.new()
  var v_filename = get_journal_filename(route_id, FILE_TYPE.VERSION)
  if v_file.open(v_filename, File.READ) != OK:
    return true

  var v_data = v_file.get_as_text().strip_edges(true, true).to_lower()
  v_file.close()

  var meta_version = meta.get_version_str()

  return v_data == meta_version

func save_journal_version(route_id):
  var v_file = File.new()
  var v_filename = get_journal_filename(route_id, FILE_TYPE.VERSION)
  if v_file.open(v_filename, File.WRITE) != OK:
    print("Could not open journal '", v_filename,"': ", v_file.get_error())
    return

  v_file.store_string(meta.get_version_str())
  v_file.close()

func rename_corrupted_files(route_id):
  var dir = Directory.new()
  if dir.open("user://") == OK:
    dir.rename("route-" + var2str(int(route_id)) + ".journal", "corrupt_route-" + var2str(int(route_id)) + ".journal")
    dir.rename("route-" + var2str(int(route_id)) + ".version", "corrupt_route-" + var2str(int(route_id)) + ".version")

func get_journal_file_reader(route_id):
  var file = File.new()
  var filename = get_journal_filename(route_id)
  if file.open(filename, File.READ) == OK:
    if not check_journal_version(route_id):
      print("Could not open journal '", filename,"': Invalid journal version")
      file.close()
      rename_corrupted_files(route_id)
      profile_data["saves"].erase(route_id)
      return
    return file
  else:
    print("Could not open journal '", filename,"': ", file.get_error())

func get_journal_file_writer(route_id):
  var file = File.new()
  var filename = get_journal_filename(route_id)
  if file.open(filename, File.WRITE) == OK:
    save_journal_version(route_id)
    return file
  else:
    print("Could not open journal '", filename,"': ", file.get_error())

func add_journal(route_id):
  profile_data["saves"].append(route_id)

func erase_journal(route_id):
  var dir = Directory.new()
  if dir.open("user://") == OK:
    dir.remove(get_journal_filename(route_id))
    dir.remove(get_journal_filename(route_id, FILE_TYPE.VERSION))
    profile_data["saves"].erase(route_id)

func get_journals():
  return profile_data["saves"]

func get_player_name(route_id):
  var file = get_journal_file_reader(route_id)
  if file == null:
    return
  var data = {}
  var text = file.get_as_text()
  data.parse_json(text)
  file.close()
  var sector_data
  for sector in data["sectors"]:
    if sector["id"] == data["current_sector"]:
      sector_data = sector
  return sector_data["actors"][int(data["player_actor_id"])]["name"]

func save():
  var file = File.new()
  file.open("user://profile.meta", File.WRITE)
  file.store_string(profile_data.to_json())
  file.close()
