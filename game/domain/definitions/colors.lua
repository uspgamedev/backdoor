
local Color = require 'common.color'

local COLORS = {}

COLORS.NEUTRAL = Color.fromInt {0xff, 0xff, 0xff, 0xff}
COLORS.TRANSP = Color.fromInt {0xff, 0xff, 0xff, 0x00}
COLORS.SEMITRANSP = Color.fromInt {0xff, 0xff, 0xff, 0x80}
COLORS.BLACK = Color.fromInt {0x06, 0x06, 0x08, 0xff}
COLORS.VOID = Color.fromInt {0, 0, 0, 0}
COLORS.HALF_VISIBLE = Color.fromInt {0x80, 0x80, 0x80, 0xff}
COLORS.LIGHT_GRAY = Color:new {.7, .7, .7, 1}
COLORS.GRAY = Color.fromInt {0x4a, 0x54, 0x62, 0xff}
COLORS.DARK = Color.fromInt {0x1f, 0x1f, 0x1f, 0xff}
COLORS.DARKER = Color.fromInt {12, 12, 12, 255}
COLORS.BACKGROUND = COLORS.BLACK
COLORS.EXIT = Color.fromInt {0x77, 0xba, 0x99, 0xff}
COLORS.FLOOR1 = Color.fromInt {25, 73, 95, 0xff}
COLORS.FLOOR2 = Color.fromInt {25, 73, 95 + 20, 0xff}

COLORS.HUD_BG = Color:new {12/256, 12/256, 12/256, 1}

COLORS.EMPTY = Color:new {0.2, .15, 0.05, 1}
COLORS.WARNING = Color:new {1, 0.8, 0.2, 1}
COLORS.VALID = Color:new {0, 0.7, 1, 1}
COLORS.INVALID = Color.fromInt {0x3b, 0x17, 0x25, 0xff}
COLORS.NOTIFICATION = Color.fromInt {0xD9, 0x53, 0x4F, 0xff}
COLORS.SUCCESS = Color.fromInt {0x33, 0xAA, 0x3F, 0xff}

COLORS.PLAY  = Color.fromInt {0xa3, 0x78, 0x71, 0xff}

COLORS.COR = Color.fromInt {0xf9, 0xa3, 0x1b, 0xff}
COLORS.ARC = Color.fromInt {0x79, 0x3a, 0x80, 0xff}
COLORS.ANI = Color.fromInt {0x14, 0xa0, 0x2e, 0xff}
COLORS.NONE = Color.fromInt {0x6d, 0x75, 0x8d, 0xff}
COLORS.PP = Color.fromInt {0x28, 0x5c, 0xc4, 255}
COLORS.FOCUS = Color.fromInt {0xbc, 0x4a, 0x9b, 0xff}
COLORS.HALF_EXHAUSTION = Color.fromInt {0x79, 0x3a, 0x80, 0xff}

COLORS.FLASH_DRAW = Color.fromInt { 99, 252, 255, 255 }
COLORS.FLASH_ANNOUNCE = Color:new{ 1, 1, 1, 1 }
COLORS.FLASH_DISCARD = Color.fromInt { 255, 135, 43, 255 }
COLORS.FLASH_EQUIP = Color:new{ .1, .8, .1, 1 }

return COLORS
