
local RES = require 'resources'

local _loadTexture = RES.loadTexture
local TEX = {}

function TEX.get(name)
  local g = love.graphics
  return setmetatable(
    {
      draw = function (t, ...)
        g.draw(_loadTexture(name), ...)
      end
    },
    {
      __index = function(t, key)
        local self = _loadTexture(name)
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

return TEX

