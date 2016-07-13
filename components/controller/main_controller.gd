
extends "res://components/controller/default_controller.gd"

const Action = preload("res://model/action.gd")

var player
var hand
var display_popup
var upgrades_popup

func event_save():
  get_node("/root/captains_log/scene_manager").close_route()

func event_idle():
  player.add_action(Action.Idle.new())

func event_up():
  move(Vector2(0, -1))

func event_down():
  move(Vector2(0, 1))

func event_right():
  move(Vector2(1, 0))

func event_left():
  move(Vector2(-1, 0))

func move(direction):
  if player.is_ready():
    var map = get_node("../../map")
    var target_pos = map.get_actor_body(player).pos + direction
    var body = map.get_body_at(target_pos)
    if body != null:
      player.add_action(Action.MeleeAttack.new(body))
    else:
      player.add_action(Action.Move.new(target_pos))

func set_player_map(player, hand):
  self.player = player
  self.hand = hand
  display_popup = get_node("../CardDisplay")
  upgrades_popup = get_node("../UpgradesDisplay")

func event_next_sector():
  player.add_action(Action.ChangeSector.new(1))

func event_create_slime():
  var map = get_node("../../map")
  get_node("/root/captains_log/monsters/Slime").create(map, Vector2(4,4))

func event_display_card():
  self.disable()
  self.display_popup.connect("close_popup", self, "restore_input")
  self.display_popup.display(hand.get_selected_card())

func event_show_upgrades():
  self.disable()
  self.upgrades_popup.connect("close_popup", self, "restore_input")
  self.upgrades_popup.display(player.upgrades)

func event_focus_next():
  hand.next_card()

func event_focus_prev():
  hand.prev_card()

func event_select():
  if get_node("/root/sector/HUD/CardDisplay").is_hidden():
    hand.get_selected_cardsprite().connect("selecting_target", self, "block_input")
    hand.get_selected_cardsprite().connect("target_selected", self, "restore_input")
    hand.user_selected_card()

func block_input():
  self.disable()

func restore_input():
  self.enable()
