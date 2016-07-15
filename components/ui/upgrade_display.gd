extends Control

const CardSprite = preload("res://components/ui/card_sprite.gd")
const CardItem = preload("res://components/ui/card_list_item.tscn")

signal close_popup

func clear():
	for child in self.get_node("UpgradeDialog/Panel/UpgradeList").get_children():
		child.free()

func display(upgrades):
	self.clear()

	self.get_node("UpgradeDialog").show_modal(true)

	self.get_node("UpgradeDialog").enable()

	for upg in upgrades:
		var item = CardItem.instance()
		item.get_node("CardHook/Card").free()

		var card_sprite = CardSprite.create(upg)
		card_sprite.set_name("Card")

		item.get_node("CardHook").add_child(card_sprite)
		item.get_node("CardName").set_text(card_sprite.get_node("Name").get_text())
		card_sprite.get_node("Name").free()

		self.get_node("UpgradeDialog/Panel/UpgradeList").add_child(item)


func is_hidden():
	return self.get_node("UpgradeDialog").is_hidden()

func hide():
	emit_signal("close_popup")
	self.get_node("UpgradeDialog").hide()
