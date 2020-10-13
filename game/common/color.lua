
local math = require 'common.math'
local vec3 = require 'cpml'.vec3

local Color = require 'lux.prototype' :new { __type = 'color' }

local function _err_type_mismatch(a, b, op)
  return error(string.format("Invalid operation with color (%s %s %s)",
                             type(a), op, type(b)))
end

function Color:__init()
  for i = 1, 4 do
    local ccode = self[i]
    local ccode_type = type(ccode)
    self[i] = ccode or 1
    assert(type(ccode == 'number'), "Cannot create color using non-number value!")
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
  elseif type(a) == 'number' and type(b) == 'table' and b.__type == 'color' then
    return Color:new {b[1] * a, b[2] * a, b[3] * a, b[4] * a}
  end
  return _err_type_mismatch(a, b, '*')
end

function Color.__add(a, b)
  if type(a) == 'table' and type(b) == 'table'
     and a.__type == 'color' and b.__type == 'color' then
    return Color:new {
      math.min(1, a[1] + b[1]),
      math.min(1, a[2] + b[2]),
      math.min(1, a[3] + b[3]),
      math.min(1, a[4] + b[4]),
    }
  end
  return _err_type_mismatch(a, b, '+')
end

function Color.__sub(a, b)
  return Color.__add(a, -1*b)
end

function Color:__tostring()
  return string.format("Color(%03d, %03d, %03d, %03d)",
                       math.round(self[1] * 255),
                       math.round(self[2] * 255),
                       math.round(self[3] * 255),
                       math.round(self[4] * 255))
end

function Color:unpack()
  return self[1], self[2], self[3], self[4]
end

function Color:withAlpha(x)
  return Color:new({self[1], self[2], self[3], x})
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
      c[i] = (r[i] or 1) / 255
    end
    return Color:new(c)
  end
  return Color:new {r/255, g/255, b/255, (a or 1)/255}
end

return Color

