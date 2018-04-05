
local Color = require 'lux.prototype' :new { __type = 'color' }

function Color:__init()
  for i = 1, 4 do
    local ccode = self[i]
    local ccode_type = type(ccode)
    self[i] = ccode or 1
    assert(type(ccode == 'number') and ccode >= 0 and ccode <= 1,
           ("Invalid color ccode %s:%s"):format(ccode, ccode_type) ..
           "Colors are represented with normalized floats (between 0 and 1).")
  end
end

function Color.__mul(a, b)
  if type(a) == 'table' and a.__type == 'color' and type(b) == 'table' and b.__type == 'color' then
    return Color:new {
      a[1] * b[1],
      a[2] * b[2],
      a[3] * b[3],
      a[4] * b[4],
    }
  elseif type(a) == 'table' and a.__type == 'color' and type(b) == 'number' then
    return Color:new {a[1] * b, a[2] * b, a[3] * b, a[4] * b}
  elseif type(b) == 'number' and type(b) == 'table' and b.__type == 'color' then
    return Color:new {b[1] * a, b[2] * a, b[3] * a, b[4] * a}
  end
end

function Color:unpack()
  return self[1], self[2], self[3], self[4]
end

--- Converts HSV to RGB. (input and output range: 0 - 255)
--  From: https://love2d.org/wiki/HSV_color
function Color.fromHSV(h, s, v, a)
  if s <= 0 then return v,v,v end
  h, s, v = h/256*6, s/255, v/255
  local c = v*s
  local x = (1-math.abs((h%2)-1))*c
  local m,r,g,b = (v-c), 0,0,0
  if h < 1     then r,g,b = c,x,0
  elseif h < 2 then r,g,b = x,c,0
  elseif h < 3 then r,g,b = 0,c,x
  elseif h < 4 then r,g,b = 0,x,c
  elseif h < 5 then r,g,b = x,0,c
  else              r,g,b = c,0,x
  end return Color:new {(r+m), (g+m), (b+m), a}
end

function Color.fromInt(r, g, b, a)
  local c = {}
  if type(r) == "table" then
    for i = 1, 4 do
      c[i] = r[i] / 255
    end
    return Color:new(c)
  end
  return Color:new {r/255, g/255, b/255, (a or 1)/255}
end

return Color

