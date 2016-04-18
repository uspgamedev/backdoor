
extends ProgressBar

var player

func _ready():
	player = get_node("/root/player")
	player.connect("spent_action", self, "_on_player_action")
	set_process(true)

func _on_player_action():
	set_max(player.cooldown)
	set_min(0)
	set_value(0)

func _process(delta):
	set_value(get_max() - player.cooldown)
