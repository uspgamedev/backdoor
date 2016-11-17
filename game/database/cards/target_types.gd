
const NONE = 0
const BODY_ONLY = 1
const EMPTY_ONLY = 2
const ANY = 3

const NAME = [
  "none", "body_only", "empty_only", "any"
]

class Checker:
  var map
  var type
  var max_range
  func _init(map, type, max_range):
    self.map = map
    self.type = type
    self.max_range = max_range
  func pvt_dist(actor, target):
    var d = target - actor.get_body_pos()
    return abs(d.x) + abs(d.y)
  func is_any(actor, target):
    return map.is_empty_space(target)
  func is_body_only(actor, target):
    return map.get_body_at(target) != null
  func is_empty_only(actor, target):
    return map.is_empty_space(target) and map.get_body_at(target) == null
  func check(actor, target):
    return (self.max_range < 1 or pvt_dist(actor, target) <= self.max_range) \
      and self.call("is_" + NAME[self.type], actor, target)
