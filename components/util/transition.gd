
extends Node2D

const BLACK = Color(42.0/255, 26.0/255, 31.0/255, 1.0)
const INVISIBLE_BLACK = Color(42.0/255, 26.0/255, 31.0/255, 0)

onready var tween = get_node("tween")
onready var overlay = get_node("overlay")

signal start_transition()
signal end_transition()

func fade_to_black(seconds):
  emit_signal("start_transition")
  tween.interpolate_method( overlay, "set_color", INVISIBLE_BLACK, BLACK, seconds, Tween.TRANS_QUAD, Tween.EASE_OUT, 0)
  tween.start()
  yield(tween, "tween_complete")
  emit_signal("end_transition")

func unfade_from_black(seconds):
  emit_signal("start_transition")
  print("unfading start!")
  tween.interpolate_method( overlay, "set_color", BLACK, INVISIBLE_BLACK, seconds, Tween.TRANS_QUAD, Tween.EASE_IN, 0)
  tween.start()
  yield(tween, "tween_complete")
  emit_signal("end_transition")
  print("unfading end!")

func create_viewport_sized_polygon():
  var viewport_rect_pos = get_viewport().get_visible_rect().pos
  var viewport_rect_size = get_viewport().get_visible_rect().size
  var polygon_shape = [ viewport_rect_pos,
    viewport_rect_pos + Vector2(viewport_rect_size.x, 0),
    viewport_rect_pos + viewport_rect_size,
    viewport_rect_pos + Vector2(0, viewport_rect_size.y) ]
  return polygon_shape

func _ready():
  overlay.set_polygon(create_viewport_sized_polygon())
  overlay.set_color(BLACK)
  unfade_from_black(1.0)
