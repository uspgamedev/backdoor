extends Control

const CardSprite = preload("res://scenes/hud/card_sprite.gd")
const CardItem = preload("res://scenes/hud/card_list_item.xscn")

func clear():
	for child in self.get_node("UpgradeDialog/Panel/UpgradeList").get_children():
		child.queue_free()

func display(upgrades):
	self.clear()

	self.get_node("UpgradeDialog").show()

	for upg in upgrades:
		var item = CardItem.instance()
		var card = CardSprite.create(upg)
		card.set_name("Card")

		item.get_node("CardHook").add_child(card)
		item.get_node("CardName").set_text(card.get_node("Name").get_text())
		item.get_node("CardHook/Card/Name").hide()
		item.get_node("CardHook/Card/Name").queue_free()

		self.get_node("UpgradeDialog/Panel/UpgradeList").add_child(item)


func is_hidden():
	return self.get_node("UpgradeDialog").is_hidden()

func hide():
	self.get_node("UpgradeDialog").hide()
