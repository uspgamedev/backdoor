local RES = require 'resources'

local _font = {}

function _font.get(name, size)

  return RES.loadFont(name, size)

end

function _font.set(name_or_font, size)
  if type(name_or_font) == "string" then
    local font = RES.loadFont(name_or_font, size)
    love.graphics.setFont(font)
    return font
  else
    love.graphics.setFont(name_or_font)
    return name_or_font
  end
end

return _font
