
const EMPTY = -1
const FLOOR = 0
const WALL = 1
const WALL_TOP = 2
const WALL_TOP_RIGHT = 3
const WALL_RIGHT = 4
const WALL_BOTTOM_RIGHT = 5
const WALL_BOTTOM = 6
const WALL_BOTTOM_LEFT = 7
const WALL_LEFT = 8
const WALL_TOP_LEFT = 9
const WALL_CORNER_TOP_RIGHT = 10
const WALL_CORNER_BOTTOM_RIGHT = 11
const WALL_CORNER_BOTTOM_LEFT = 12
const WALL_CORNER_TOP_LEFT = 13
const ANY = -2
const ANY_BUT_WALL = -3

var map = []
var width = 0
var height = 0

func _init(w, h):
    self.width = w
    self.height = h
    self.map.resize(h)
    for i in range(w):
        self.map[i] = []
        self.map[i].resize(w)
        for j in range(h):
            self.map[i][j] = EMPTY

func get_width():
    return self.width

func get_height():
    return self.height

func get_tile(i, j):
    return self.map[i][j]

func add_random():
    var i = 1 + int(randf() * (self.height-1))
    var j = 1 + int(randf() * (self.width-1))
    self.map[i][j] = WALL
    print("Adding random wall tile:")
    print("[ " + str(i) + ", " + str(j) + " ]")
    print("Tile: " + str(self.map[i][j]))

func apply_pattern_rules(patterns, value):
    var newmap = []
    newmap.resize(self.height)
    for i in range(self.width):
        newmap[i] = []
        newmap[i].resize(self.width)
        for j in range(self.height):
            newmap[i][j] = EMPTY

    for i in range(1, self.width - 1):
        for j in range(1, self.height - 1):
            for pattern in patterns:
                var change = true
                for di in range(-1,2):
                    for dj in range(-1,2):
                        if not ( pattern[di+1][dj+1] == ANY \
                        or self.map[i+di][j+dj] == pattern[di+1][dj+1] \
                        or (pattern[di+1][dj+1] == ANY_BUT_WALL and self.map[i+di][j+dj] != WALL) ):
                            change = false
                if change:
                    newmap[i][j] = value
                    break
                else:
                    newmap[i][j] = self.map[i][j]
    self.map = newmap
