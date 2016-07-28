
extends Sprite

const HighlightMap = preload("res://components/ui/highlight_map.gd")

#FIXME: move to separate script
class Queue:
  var values
  var tail
  var head
  func _init():
    values = []
    tail = 0
    head = 0
    values.resize(512)
  func is_empty():
    return tail == head
  func push(value):
    values[tail] = value
    tail = (tail+1)%values.size()
  func pop():
    var value = values[head]
    head = (head+1)%values.size()
    return value

const DIRS = [
  Vector2(0,-1), #UP
  Vector2(1,0),  #RIGHT
  Vector2(0,1),  #DOWN
  Vector2(-1,0)  #LEFT
]

var map
var origin
var target_
var check
var aoe_

signal target_chosen()

func select(the_check, area):
  #FIXME: keep reference in attribute, also rename it to lowercase
  get_node("Controller").connect("move_selection", self, "move_to")
  get_node("Controller").connect("confirm", self, "confirm")
  get_node("Controller").connect("cancel", self, "cancel")
  get_node("Controller").enable()
  aoe_ = area
  target_ = null
  map = get_node("/root/sector/map")
  var main = get_node("/root/sector")
  check = the_check
  origin = main.player.get_body().pos
  for dir in DIRS:
    if move_to(dir):
      break
  if target_ == null:
    if check.call_func(map.get_parent().player, origin):
      target_ = origin
    else:
      return false
  set_process(true)
  show()
  return true

func disable():
  var main = get_node("/root/sector")
  hide()
  get_node("Controller").disable()
  map.get_node("highlights").clear()
  set_process(false)
  emit_signal("target_chosen")

func confirm():
  disable()

func cancel():
  target_ = null
  disable()

func get_target():
  return target_

func inside(pos, dir):
  var relative = pos - origin
  var plus = relative.dot(dir)
  var reach = abs(plus)
  var p = relative.dot(Vector2(dir.y, dir.x))
  var q = relative.dot(dir)
  return q >= 0 and q <= 16 and p < reach and p > -reach

func move_to(dir):
  # bfs
  var found = false
  var queue = Queue.new()
  var checked = {}
  checked[origin] = true
  queue.push(origin+dir)
  while not queue.is_empty():
    var next = queue.pop()
    checked[next] = true
    # Choose next as target if it is valid
    if check.call_func(map.get_parent().player, next):
      target_ = next
      found = true
      break
    # If not, expand the search
    for next_dir in DIRS:
      var candidate = next + next_dir
      if not checked.has(candidate) and inside(candidate, dir):
        queue.push(candidate)
  if target_ != null:
    origin = target_
  return found

func _process(delta):
  if target_ != null:
    # update cursor position
    var floors = map.get_node("floors")
    set_pos(floors.map_to_world(target_))
    # update highlight
    var hls = map.get_node("highlights")
    if aoe_ != null:
      var format
      var center
      if typeof(aoe_.format) != TYPE_ARRAY:
        format = aoe_.format.call_func(map.get_parent().player, target_)
      else:
        format = aoe_.format
      if typeof(aoe_.center) != TYPE_VECTOR2:
        center = aoe_.center.call_func(map.get_parent().player, target_)
      else:
        center = aoe_.center
      hls.clear()
      hls.add_area(target_, format, center, HighlightMap.AOE)
