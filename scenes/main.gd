
extends Node2D

const Action   = preload("res://model/action.gd")

var player
var map
var done
var next_sector
var hand
var display_popup
var upgrades_popup

onready var deck_view = get_node("HUD/deck")

func _init():
  print("sector created")

func _ready():
  #get_node("/root/captains_log").start()
  print("sector ready")

func set_player(the_player):
  player = the_player
  get_node("HUD/UI_hook/CooldownBar").set_player(the_player)
  get_node("HUD/UI_hook/Hand").set_player(the_player)
  hand = get_node("HUD/UI_hook/Hand")
  deck_view.set_player(the_player)
  player.connect("equipped_item", get_node("HUD/base/item_stats"), "change_item")
  display_popup = get_node("HUD/CardDisplay")
  upgrades_popup = get_node("HUD/UpgradesDisplay")

func close():
  get_node("HUD/UI_hook/CooldownBar").stop()
  get_node("HUD/UI_hook/Hand").stop()
  deck_view.stop()
  player.disconnect("equipped_item", get_node("HUD/base/item_stats"), "change_item")
  set_fixed_process(false)
  set_process_input(false)
  map.queue_free()
  done = true
  map = null

func new_sector():
  map = get_node("map")
  set_fixed_process(true)
  set_process_input(true)
  print("start sector")
  done = false
  next_sector = null
  manage_actors()

func set_next_sector(target):
  done = true
  next_sector = target

func manage_actors():
  while not done:
    for actor in map.actor_bodies:
      if map.get_actor_body(actor).is_dead():
        continue
      actor.step_time()
      if actor.is_ready():
        if !actor.has_action():
          yield(actor, "has_action")
        actor.use_action()
    map.check_dead_bodies()
    yield(get_tree(), "fixed_frame" )
  if next_sector != null:
    get_node("/root/route").change_sector(next_sector)

func _fixed_process(delta):
  for actor in map.actor_bodies:
    if actor != player and !actor.has_action() and actor.is_ready():
      actor.pick_ai_module().think()

func _input(event):
  if event.is_action_pressed("ui_cancel"):
    get_node("/root/captains_log").finish()
    get_tree().quit()
  if event.is_action_pressed("ui_save"):
    get_node("/root/captains_log/scene_manager").close_route()
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
    elif event.is_action_pressed("debug_create_slime"):
      get_node("/root/captains_log/monsters/Slime").create(map, Vector2(4,4))
    elif ((event.is_action_released("ui_display_card")
      or event.is_action_released("ui_focus_next")
      or event.is_action_released("ui_focus_prev")
      or event.is_action_released("ui_select")
      or event.is_action_released("ui_show_upgrades"))
      and not self.display_popup.is_hidden()):
        self.display_popup.hide()
    elif ((event.is_action_released("ui_display_card")
      or event.is_action_released("ui_focus_next")
      or event.is_action_released("ui_focus_prev")
      or event.is_action_released("ui_select")
      or event.is_action_released("ui_show_upgrades"))
      and not self.upgrades_popup.is_hidden()):
        self.upgrades_popup.hide()
    elif event.is_action_released("ui_display_card") and self.display_popup.is_hidden() and hand.get_selected_card() != null:
      self.display_popup.display(hand.get_selected_card())
    elif event.is_action_released("ui_show_upgrades") and self.upgrades_popup.is_hidden() and player != null:
      self.upgrades_popup.display(player.upgrades)

    if event.is_action_pressed("ui_idle"):
      player.add_action(Action.Idle.new())
    elif move.length_squared() > 0:
      var target_pos = map.get_actor_body(player).pos + move
      var body = map.get_body_at(target_pos)
      if body != null:
        player.add_action(Action.MeleeAttack.new(body))
      else:
        player.add_action(Action.Move.new(target_pos))
