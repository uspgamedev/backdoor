
local RES = require 'resources'

local _getFont = RES.loadFont

local FONT = {}

function FONT.set(name_or_font, size)
  local g = love.graphics
  if type(name_or_font) == "string" then
    local font = _getFont(name_or_font, size)
    g.setFont(font)
    return font
  else
    name_or_font:set()
    return name_or_font
  end
end

function FONT.get(name, size)
  return setmetatable(
    {
      set = function()
        FONT.set(name, size)
      end
    }, {
      __index = function(t, key)
        local self = _getFont(name, size)
        local method = self[key]
        if type(method) == 'function' then
          return function (_, ...)
            return method(self, ...)
          end
        else
          return method
        end
      end
    }
  )
end

return FONT

