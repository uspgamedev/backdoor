
extends Node2D

const CardSprite = preload("res://scenes/hud/card.xscn")
const Action = preload("action.gd")
var player
var cards
var focus

func _ready():
	player = get_node("/root/Node2D/TileMap/Hero")
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
			player.add_action(Action.new("use_card", focus))

func _process(delta):
	var n = cards.size()
	var angle = 30/(n+1)
	for i in range(cards.size()):
		var card = cards[i]
		if i != focus:
			card.get_node("Border").set_modulate(Color(0,0,0))
		else:
			card.get_node("Border").set_modulate(Color(1,1,1))
	for i in range(n-1, -1, -1):
		var transform = Matrix32(-deg2rad((i - (n-1)*.5)*angle), Vector2(0,1024))
		cards[i].set_transform(transform.translated(Vector2(0, -1024)))
