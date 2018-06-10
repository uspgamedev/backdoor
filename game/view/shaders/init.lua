
local SHADERLOADER = require 'lux.pack' 'view.shaders'

function SHADERLOADER:__index(k)
  local value = getmetatable(self)[k]
  local shader = love.graphics.newShader(value)
  rawset(self, k, shader)
  return shader
end

return setmetatable({}, SHADERLOADER)

