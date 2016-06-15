extends Node2D

const CardSprite = preload("res://scenes/hud/card_sprite.gd")
const Actor = preload("res://model/actor.gd")

func display(card):
	self.get_node("CardPopup/CardName").set_text(card.get_name())
	self.get_node("CardPopup/Card") = CardSprite.create(card)
	self.get_node("CardPopup/Card/Name").hide()
	self.get_node("CardPopup/DescriptionPanel/CardDescription").set_text(card.get_description())
	self.get_node("CardPopup").show()

func is_hidden():
	return self.get_node("CardPopup").is_hidden()

func hide():
	self.get_node("CardPopup").hide()