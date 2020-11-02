
local Color = require 'common.color'

return {
  IDENTITY = Color:new{ 1, 1, 1, 1},
  TRANSPARENT = Color:new{ 1, 1, 1, 0},
  BRIGHT = Color.fromInt{ 0xa6, 0xfc, 0xdb, 0xff },
  DIM = Color.fromInt{ 0x47, 0x7d, 0x85, 0xff },
  DARK = Color.fromInt{ 0x12, 0x20, 0x20, 0xff },
}

