
extends Node2D

const CardSprite = preload("res://card.xscn")
var player

func _ready():
	player = get_node("/root/Node2D/TileMap/Hero")
	set_process(true)
	player.connect("draw_card", self, "_on_player_draw")

func _on_player_draw(card):
	print("card added: ", card.name)
	var card_sprite = CardSprite.instance()
	card_sprite.get_node("Name").set_text(card.name)
	add_child(card_sprite)

func _process(delta):
	pass
