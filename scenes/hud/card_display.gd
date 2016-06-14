extends Node2D

const CardSprite = preload("res://scenes/hud/card_sprite.gd")
const Actor = preload("res://model/actor.gd")

func display(card):
	self.get_node("CardDialog/CardName").set_text(card.get_name())
	self.get_node("CardDialog/Card") = CardSprite.create(card)
	self.get_node("CardDialog/DescriptionPanel/CardDescription").set_text(card.get_description())
	self.get_node("CardDialog").show()