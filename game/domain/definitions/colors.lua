
local Color = require 'common.color'

local COLORS = {}

COLORS.NEUTRAL = Color.fromInt {0xff, 0xff, 0xff, 0xff}
COLORS.TRANSP = Color.fromInt {0xff, 0xff, 0xff, 0x00}
COLORS.SEMITRANSP = Color.fromInt {0xff, 0xff, 0xff, 0x80}
COLORS.BLACK = Color.fromInt {0x00, 0x00, 0x00, 0xff}
COLORS.VOID = Color.fromInt {0, 0, 0, 0}
COLORS.HALF_VISIBLE = Color.fromInt {0x80, 0x80, 0x80, 0xff}
COLORS.DARK = Color.fromInt {0x1f, 0x1f, 0x1f, 0xff}
COLORS.DARKER = Color.fromInt {12, 12, 12, 255}
COLORS.BACKGROUND = Color.fromInt {50, 80, 80, 255}
COLORS.EXIT = Color.fromInt {0x77, 0xba, 0x99, 0xff}
COLORS.FLOOR1 = Color.fromInt {25, 73, 95, 0xff}
COLORS.FLOOR2 = Color.fromInt {25, 73, 95 + 20, 0xff}

COLORS.HUD_BG = Color:new {12/256, 12/256, 12/256, 1}

COLORS.EMPTY = Color:new {0.2, .15, 0.05, 1}
COLORS.WARNING = Color:new {1, 0.8, 0.2, 1}
COLORS.VALID = Color:new {0, 0.7, 1, 1}
COLORS.NOTIFICATION = Color.fromInt {0xD9, 0x53, 0x4F, 0xff}
COLORS.SUCCESS = Color.fromInt {0x33, 0xAA, 0x3F, 0xff}

COLORS.STASH = Color.fromInt {0x41, 0x6e, 0x8e, 0xff}
COLORS.PLAY  = Color.fromInt {0xa3, 0x78, 0x71, 0xff}

COLORS.COR = Color.fromInt {0xbe, 0x76, 0x3a, 0xff}
COLORS.ARC = Color.fromInt {0x6e, 0x60, 0xaa, 0xff}
COLORS.ANI = Color.fromInt {0x77, 0xb9, 0x55, 0xff}
COLORS.NONE = Color.fromInt {0x77, 0x77, 0x77, 0xff}
COLORS.PP = Color.fromInt {153, 51, 153, 255}
COLORS.FOCUS = Color.fromInt {0xbc, 0x4a, 0x9b, 0xff}

COLORS.FLASH_DRAW = Color.fromInt { 99, 252, 255, 255 }
COLORS.FLASH_ANNOUNCE = Color:new{ 1, 1, 1, 1 }
COLORS.FLASH_DISCARD = Color.fromInt { 255, 135, 43, 255 }
COLORS.FLASH_EQUIP = Color:new{ .1, .8, .1, 1 }

return COLORS

