extends Control

const CardSprite = preload("res://components/ui/card_sprite.gd")
const Actor = preload("res://model/actor.gd")

onready var popup = get_node("CardPopup")

signal close_popup

func display(card):
	self.get_node("CardPopup/CardName").set_text(card.get_name())
	var card_sprite = CardSprite.create(card)

	card_sprite.set_name("Card")
	card_sprite.get_node("Name").hide()
	self.get_node("CardPopup/SpriteHook/Card").free()
	self.get_node("CardPopup/SpriteHook").add_child(card_sprite)

	self.get_node("CardPopup/DescriptionPanel/CardDescription").set_text(card.get_description())

	popup.enable()
	popup.show()

func is_hidden():
	return popup.is_hidden()

func hide():
	emit_signal("close_popup")
	popup.hide()
