
extends Node

onready var caplog = get_parent()
onready var menu = get_node("/root/menu")

func replace_scene(parent, oldscene, newscene):
	call_deferred("_deferred_replace_scene", parent, oldscene, newscene)

func _deferred_replace_scene(parent, oldscene, newscene):
	# Immediately free the current scene,
	# there is no risk here.    
	oldscene.free()
	# Add it to the active scene, as child of given parent
	parent.add_child(newscene)

func destroy_route():
	var route = get_node("/root/route")
	route.close_current_sector()
	route.queue_free()
	caplog.erase_route(route.id)
	get_tree().set_current_scene(menu)
	menu.start()