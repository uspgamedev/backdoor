
extends Node2D

const CardScene = preload("res://scenes/hud/card.xscn")
const CARD_TYPE = preload("res://model/card_ref.gd").CARD_TYPE

const Skill = preload("res://model/card_skill.gd")
const Upgrade = preload("res://model/card_upgrade.gd")
const Item = preload("res://model/card_item.gd")


const ANGLE = -atan2(1,2)
const BG_COLOR = "bg_color"
const FG_COLOR = "fg_color"

const COLOR_DICT = {
	CARD_TYPE.ARCANE: {
			BG_COLOR: Color("000e36"),
			FG_COLOR: Color("6277ff")
		},
	CARD_TYPE.ATHELITCS: {
			BG_COLOR: Color("3d0b0b"),
			FG_COLOR: Color("d95763")
		},
	CARD_TYPE.ENGINEERING: {
			BG_COLOR: Color("133b0b"),
			FG_COLOR: Color("7fd95b")
		}
}

var card

static func create(card):
	var card_sprite = CardScene.instance()
	card_sprite.card = card
	card_sprite.get_node("Name").set_text(card.get_name())
	card_sprite.get_node("Background").set_modulate(COLOR_DICT[card.card_ref.get_card_type()][BG_COLOR])
	card_sprite.get_node("Subborder").set_modulate(COLOR_DICT[card.card_ref.get_card_type()][FG_COLOR])
	card_sprite.get_node("CardClass").set_text(get_card_class(card.card_ref))
	return card_sprite

func get_card_class(card):
	if card extends Skill:
		return "Skill"
	elif card extends Upgrade:
		return "Upgrade"
	elif card extends Item:
		return "Item"
	return ""

func select():
	self.set_pos(Vector2(self.get_pos().x, -32))
	self.set_rot(0)
	self.get_node("Name").show()

func deselect():
	self.set_rot(ANGLE)
	self.get_node("Name").hide()
