
extends ProgressBar

var player

func set_player(the_player):
	player = the_player
	player.connect("spent_action", self, "_on_player_action")
	set_process(true)
	show()

func stop():
	player.disconnect("spent_action", self, "_on_player_action")
	set_process(false)
	player = null
	hide()

func _on_player_action():
	set_max(player.cooldown)
	set_min(0)
	set_value(0)

func _process(delta):
	set_value(get_max() - player.cooldown)
