
extends Node2D

const CardSprite = preload("res://scenes/hud/card_sprite.gd")
const Action = preload("res://model/action.gd")

var player = null
var focus

func _ready():
	start()

func start():
	set_process(true)
	set_process_input(true)
	show()

func stop():
	hide()
	set_process(false)
	set_process_input(false)
	player.disconnect("draw_card", self, "_on_player_draw")
	player.disconnect("consumed_card", self, "_on_player_consume")
	focus = null
	for child in get_children():
		child.queue_free()

func set_player(the_player):
	start()
	player = the_player
	player.connect("draw_card", self, "_on_player_draw")
	player.connect("consumed_card", self, "_on_player_consume")
	for card in player.hand:
		_on_player_draw(card)

func _on_player_draw(card):
	print("card added: ", card.get_name())
	var card_sprite = CardSprite.create(card)
	add_child(card_sprite)
	if focus == null:
		focus = 0

func _on_player_consume(card):
	focus = min(focus, get_child_count()-2)
	if focus < 0:
		focus = null
	for card_sprite in get_children():
		if card_sprite.card == card:
			card_sprite.queue_free()

func _input(event):
	if focus != null and get_child_count() > 0:
		if event.is_action_pressed("ui_focus_next"):
			focus = (focus+1)%get_child_count()
		elif event.is_action_pressed("ui_focus_prev"):
			focus = (focus-1+get_child_count())%get_child_count()
		elif event.is_action_pressed("ui_select") and get_node("/root/sector/HUD/CardDisplay").is_hidden():
			var card = get_child(focus).card
			var action = Action.EvokeCard.new(card)
			for option in card.get_ref().get_options(player):
				if option["type"] == "TARGET":
					var cursor = get_node("/root/sector/map/floors/cursor")
					cursor.select(option["check"])
					yield(cursor, "target_chosen")
					if cursor.target == null:
						return
					action.add_option(cursor.target)
			player.add_action(action)

func _process(delta):
	var n = get_child_count()
	for i in range(n):
		var card = get_child(n-1-i)
		card.set_pos(Vector2(48*i, 0))
		if i == focus:
			card.select()
		else:
			card.deselect()

func get_selected_card():
	if player.hand.size() <= 0:
		return null;
	return get_child(focus).card