
extends Node2D

const CardSprite = preload("res://scenes/hud/card.xscn")
const Action = preload("res://model/action.gd")
const ANGLE = atan2(1,2)

var player
var cards
var focus

func _ready():
	player = get_node("/root/current/map/Hero")
	cards = []
	set_process(true)
	set_process_input(true)
	player.connect("draw_card", self, "_on_player_draw")

func _on_player_draw(card):
	print("card added: ", card.name)
	var card_sprite = CardSprite.instance()
	card_sprite.get_node("Name").set_text(card.name)
	cards.append(card_sprite)
	add_child(card_sprite)
	if focus == null:
		focus = 0

func _input(event):
	if focus != null:
		if event.is_action_pressed("ui_focus_next"):
			focus = (focus+1)%cards.size()
		elif event.is_action_pressed("ui_focus_prev"):
			focus = (focus-1+cards.size())%cards.size()
		elif event.is_action_pressed("ui_select"):
			player.add_action(Action.Idle.new())

func _process(delta):
	var n = cards.size()
	for i in range(n):
		cards[n-i-1].set_pos(Vector2(i*48, 0))
		cards[n-i-1].set_rot(-ANGLE)
