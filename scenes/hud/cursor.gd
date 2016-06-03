
extends Sprite

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

signal target_chosen(target)

func select(the_check):
	map = get_node("/root/sector/map")
	var main = get_node("/root/sector")
	check = the_check
	origin = main.player.get_body().pos
	move_to(DIRS[0])
	main.set_process_input(false)
	main.get_node("HUD/UI_hook/Hand").set_process_input(false)
	set_process_input(true)
	show()

func confirm():
	var main = get_node("/root/sector")
	hide()
	main.set_process_input(true)
	main.get_node("HUD/UI_hook/Hand").set_process_input(true)
	set_process_input(false)
	emit_signal("target_chosen", target)

func inside(pos, dir): 
	var relative = pos - origin
	var plus = relative.dot(dir)
	var reach = abs(plus)
	var p = relative.dot(Vector2(dir.y, dir.x))
	var q = relative.dot(dir)
	return q > 0 and p < reach and p > -reach

func move_to(dir):
	# bfs
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
			break
		# If not, expand the search
		for dir in DIRS:
			var candidate = next + dir
			if not checked.has(candidate) and inside(candidate, dir):
				queue.push(candidate)
	var floors = map.get_node("floors")
	set_pos(floors.map_to_world(target))
	origin = target

func _input(event):
	var move = Vector2(0,0)
	if event.is_action_pressed("ui_down"):
		move.y += 1
	elif event.is_action_pressed("ui_up"):
		move.y -= 1
	elif event.is_action_pressed("ui_right"):
		move.x += 1
	elif event.is_action_pressed("ui_left"):
		move.x -= 1
	move_to(move)
	if event.is_action_pressed("ui_select"):
		confirm()
