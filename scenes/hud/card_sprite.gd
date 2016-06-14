
extends Node2D

const CardScene = preload("res://scenes/hud/card.xscn")
const ANGLE = -atan2(1,2)

var card

static func create(card):
	var card_sprite = CardScene.instance()
	card_sprite.card = card
	card_sprite.get_node("Name").set_text(card.get_name())
	return card_sprite

func select():
	self.set_pos(Vector2(self.get_pos().x, -32))
	self.set_rot(0)
	self.get_node("Name").show()

func deselect():
	self.set_rot(ANGLE)
	self.get_node("Name").hide()
