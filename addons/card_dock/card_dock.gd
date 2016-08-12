tool
extends EditorPlugin

const DockScene = preload("res://addons/card_dock/card_dock.tscn")

var dock

func _enter_tree():
	dock = DockScene.instance()
	dock.plugin = self
	add_control_to_container(CONTAINER_CANVAS_EDITOR_SIDE, dock)

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
