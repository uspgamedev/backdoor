
extends Object

static func get_file_as_text(filepath):
  var datafile = File.new()
  var datatext
  datafile.open(filepath, File.READ)
  datatext = datafile.get_as_text()
  datafile.close()
  return datatext
