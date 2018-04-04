
local Color = require 'lux.prototype' :new { __type = 'color' }

function Color.__mul(a, b)
  if type(a) == 'table' and a.__type == 'color' and type(b) == 'table' and b.__type == 'color' then
    return Color:new { a[1] * b[1] / 255,
                      a[2] * b[2] / 255,
                      a[3] * b[3] / 255,
                      a[4] * b[4] / 255
    }
  elseif type(a) == 'table' and a.__type == 'color' and type(b) == 'number' then
    return Color:new { a[1] * b, a[2] * b, a[3] * b, a[4] * b }
  elseif type(b) == 'number' and type(b) == 'table' and b.__type == 'color' then
    return Color:new { b[1] * a, b[2] * a, b[3] * a, b[4] * a }
  end
end

function Color:__init()
  for i = 1, 4 do
    self[i] = self[i] or 0xff
  end
end

local COLORS = {}

COLORS.NEUTRAL = Color:new {0xff, 0xff, 0xff, 0xff}
COLORS.BLACK = Color:new {0x00, 0x00, 0x00, 0xff}
COLORS.HALF_VISIBLE = Color:new {0x80, 0x80, 0x80, 0xff}
COLORS.TRANS = Color:new {0xff, 0xff, 0xff, 0x00}
COLORS.DARK = Color:new {0x1f, 0x1f, 0x1f, 0xff}
COLORS.BACKGROUND = Color:new {50, 80, 80, 255}
COLORS.EXIT = Color:new {0x77, 0xba, 0x99, 0xff}
COLORS.FLOOR1 = Color:new {25, 73, 95, 0xff}
COLORS.FLOOR2 = Color:new {25, 73, 95 + 20, 0xff}

COLORS.NOTIFICATION = Color:new {0xD9, 0x53, 0x4F, 0xff}
COLORS.WARNING = Color:new {0xF0, 0xAD, 0x4E, 0xff}
COLORS.VALID = Color:new {0x00, 0x7b, 0xff, 0xff}
COLORS.SUCCESS = Color:new {0x33, 0xAA, 0x3F, 0xff}

COLORS.STASH = Color:new {0x41, 0x6e, 0x8e, 0xff}
COLORS.PLAY  = Color:new {0xa3, 0x78, 0x71, 0xff}

COLORS.COR = Color:new {0xbe, 0x76, 0x3a, 0xff}
COLORS.ARC = Color:new {0x6e, 0x60, 0xaa, 0xff}
COLORS.ANI = Color:new {0x77, 0xb9, 0x55, 0xff}

return COLORS

