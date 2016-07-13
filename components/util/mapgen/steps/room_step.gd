
extends "res://components/util/mapgen/step.gd"

class Room:
  var i_
  var j_
  var w_
  var h_
  func _init(i, j, w, h):
    i_ = i
    j_ = j
    w_ = w
    h_ = h
  func left():
    return j_
  func top():
    return i_
  func right():
    return j_+w_
  func bottom():
    return i_+h_
  func intersects(other):
    if right() < other.left():
      return false
    if bottom() < other.top():
      return false
    if left() > other.right():
      return false
    if top() > other.bottom():
      return false
    return true
  func put_in(map_grid):
    for i in range(h_+1):
      if abs(i - 5) > 1:
        map_grid.set_tile(i_ + i, j_, WALL)
      map_grid.set_tile(i_ + i, j_ + w_, WALL)
    for j in range(w_):
      map_grid.set_tile(i_, j_ + j, WALL)
      map_grid.set_tile(i_ + h_, j_ + j, WALL)

var rooms_

func new_room(w, h):
  var i = 1 + 2*(randi()%((h-10)/2))
  var j = 1 + 2*(randi()%((w-10)/2))
  var rw = 10
  var rh = 10
  var room = Room.new(i, j, rw, rh)
  for other in rooms_:
    if room.intersects(other):
      return
  rooms_.push_back(room)

func place_rooms(map_grid):
  for room in rooms_:
    room.put_in(map_grid)

func apply(map, w, h):
  randomize()
  var map_grid = MapGrid.clone(map, w, h)
  rooms_ = []
  for n in range(20):
    new_room(w, h)
  place_rooms(map_grid)
  return map_grid
