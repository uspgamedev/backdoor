
extends Node2D

const CardScene = preload("res://scenes/hud/card.xscn")

var card

static func create(card):
	var card_sprite = CardScene.instance()
	card_sprite.card = card
	card_sprite.get_node("Name").set_text(card.get_name())
	return card_sprite
