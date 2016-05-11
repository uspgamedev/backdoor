
extends Node

func _ready():
	pass

func replace_scene(parent, oldscene, newscene):
	call_deferred("_deferred_replace_scene", parent, oldscene, newscene)

func _deferred_replace_scene(parent, oldscene, newscene):
	    # Immediately free the current scene,
	    # there is no risk here.    
	    oldscene.free()
	   # Add it to the active scene, as child of given parent
	    parent.add_child(newscene)

