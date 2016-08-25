
extends ParallaxBackground

var player_
var layer0

func _ready():
    set_process(true)

func load_parallax():
    pass
    #player_ = get_node("/root/sector").map.find_body_view(get_node("/root/sector").player.get_body())
    #layer0 = get_node("ParallaxLayer")

func _process(delta):
    pass
    #var player_pos = player_.get_pos()
    #var pos = layer0.get_pos()
    #var displacement = Vector2(player_pos.x - pos.x, player_pos.y - pos.y)
    #layer0.set_pos(pos + delta * displacement)
