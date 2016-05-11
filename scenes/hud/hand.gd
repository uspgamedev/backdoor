
extends Node2D

const CardSprite = preload("res://scenes/hud/card.xscn")
const Action = preload("res://model/action.gd")
const ANGLE = -atan2(1,2)

onready var cards = []
var player
var focus

func _ready():
	start()

func start():
	set_process(true)
	set_process_input(true)

func stop():
	set_process(false)
	set_process_input(false)
	player.disconnect("draw_card", self, "_on_player_draw")
	for child in get_children():
		child.queue_free()

func set_player(the_player):
	if player != null:
		player.disconnect("draw_card", self, "_on_player_draw")
	player = the_player
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
		var card = cards[n-1-i]
		if i == focus:
			card.set_pos(Vector2(i*48, -32))
			card.set_rot(0)
		else:
			card.set_pos(Vector2(i*48, 0))
			card.set_rot(ANGLE)
