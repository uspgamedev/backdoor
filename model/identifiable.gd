
extends Object

var id_

static func find(identifiable_list, id):
	for identifiable in identifiable_list:
		if identifiable.get_id() == id:
			return identifiable

func _init(id):
	id_ = id

func get_id():
	return id_
