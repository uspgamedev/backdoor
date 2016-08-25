tool
extends Container

var plugin
var test

func _on_enter_tree():
	test = get_node("Contents/Test")
	test.connect("pressed", self, "_on_pressed")

func _on_exit_tree():
	test.disconnect("pressed", self, "_on_pressed")

func _on_pressed():
	var selected = plugin.get_selection().get_selected_nodes()[0]
	printt("selected:", selected.get_card_id(selected.get_node("Arcane Bolt")))
