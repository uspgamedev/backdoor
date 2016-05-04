
extends Node2D

const Action   = preload("res://model/action.gd")

var player
var map
var done
var next_sector

func _init():
	print("sector created")

func _ready():
	#get_node("/root/captains_log").start()
	print("sector ready")

func set_player(the_player):
	player = the_player
	get_node("HUD/UI_hook/CooldownBar").set_player(the_player)
	get_node("HUD/UI_hook/Hand").set_player(the_player)

func new_sector(the_player):
	map = get_node("map")
	set_fixed_process(true)
	set_process_input(true)
	print("start sector")
	done = false
	next_sector = null
	manage_actors()

func set_next_sector (target):
	done = true
	next_sector = target

func manage_actors():
	while not done:
		for actor in map.actor_bodies:
			actor.step_time()
			if actor.is_ready():
				if !actor.has_action():
					yield(actor, "has_action")
				actor.use_action()
		yield(get_tree(), "fixed_frame" )
	get_node("/root/route").change_sector(next_sector)

func _fixed_process(delta):
	for actor in map.actor_bodies:
		if actor != player and !actor.has_action() and actor.is_ready():
			actor.pick_ai_module().think()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_node("/root/captains_log").finish()
	if player.is_ready():
		var move = Vector2(0,0)
		if event.is_action_pressed("ui_down"):
			move.y += 1
		elif event.is_action_pressed("ui_up"):
			move.y -= 1
		elif event.is_action_pressed("ui_right"):
			move.x += 1
		elif event.is_action_pressed("ui_left"):
			move.x -= 1
		elif event.is_action_pressed("debug_next_sector"):
			player.add_action(Action.ChangeSector.new(1))
		if event.is_action_pressed("ui_idle"):
			player.add_action(Action.Idle.new())
		elif move.length_squared() > 0:
			var target_pos = map.get_actor_body(player).pos + move
			var body = map.get_body_at(target_pos)
			if body != null:
				player.add_action(Action.MeleeAttack.new(body))
			else:
				player.add_action(Action.Move.new(target_pos))

