
extends Control

const MAX_DECK_SIZE = 20

var deck_draw
var player = null

func set_player(the_player):
  player = the_player
  deck_draw.set_min(0)
  deck_draw.set_max(MAX_DECK_SIZE)
  print("max: ", str(deck_draw.get_max()))
  self.show()
  player.connect("update_deck", self, "update_deck")
  update_deck()

func stop():
  hide()
  set_process(false)
  set_process_input(false)
  player.disconnect("update_deck", self, "update_deck")
  deck_draw.hide()

func _ready():
  deck_draw = ProgressBar.new()
  deck_draw.set_pos(Vector2(0,0))
  deck_draw.set_size(self.get_size())
  deck_draw.show()
  add_child(deck_draw)
  self.hide()

func update_deck():
  deck_draw.set_value(player.deck.size());
  print("now: ", str(deck_draw.get_max()))