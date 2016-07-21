
extends Sprite

const HighlightMap = preload("res://components/ui/highlight_map.gd")

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
var target
var check
var aoe_

signal target_chosen()

func select(the_check, area):
  get_node("Controller").connect("move_selection", self, "move_to")
  get_node("Controller").connect("confirm", self, "confirm")
  get_node("Controller").connect("cancel", self, "cancel")
  get_node("Controller").enable()
  aoe_ = area
  target = null
  map = get_node("/root/sector/map")
  var main = get_node("/root/sector")
  check = the_check
  origin = main.player.get_body().pos
  for dir in DIRS:
    if move_to(dir):
      break
  if target == null:
    if check.call_func(map.get_parent().player, origin):
      target = origin
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
  target = null
  disable()

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
      target = next
      found = true
      break
    # If not, expand the search
    for next_dir in DIRS:
      var candidate = next + next_dir
      if not checked.has(candidate) and inside(candidate, dir):
        queue.push(candidate)
  if target != null:
    origin = target
    if aoe_ != null:
      var format
      var center
      if typeof(aoe_.format) != TYPE_ARRAY:
        format = aoe_.format.call_func(map.get_parent().player, target)
      else:
        format = aoe_.format
      if typeof(aoe_.center) != TYPE_VECTOR2:
        center = aoe_.center.call_func(map.get_parent().player, target)
      else:
        center = aoe_.center
      var hls = map.get_node("highlights")
      hls.clear()
      hls.add_area(target, format, center, HighlightMap.AOE)
  return found

func _process(delta):
  var floors = map.get_node("floors")
  if target != null:
    set_pos(floors.map_to_world(target))
