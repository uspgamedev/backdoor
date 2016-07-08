extends Control

const CardSprite = preload("res://components/ui/card_sprite.gd")
const Actor = preload("res://model/actor.gd")

onready var popup = get_node("CardPopup")

signal close_popup

func display(card):
	self.get_node("CardPopup/CardName").set_text(card.get_name())
	self.get_node("CardPopup/Card") = CardSprite.create(card)
	self.get_node("CardPopup/Card/Name").hide()
	self.get_node("CardPopup/DescriptionPanel/CardDescription").set_text(card.get_description())
	popup.show()

func is_hidden():
	return popup.is_hidden()

func hide():
	emit_signal("close_popup")
	popup.hide()
