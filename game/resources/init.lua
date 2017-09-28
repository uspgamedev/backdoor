local DB = require 'database'

local RES = {}

local _rescache = {
  font = {},
  image = {},
  sfx = {},
  bgm = {},
}

function RES.loadFont(font_name, size)
  local font_group = _rescache.font[font_name] or {}
  local font = font_group[size] if not font then
    local path = DB.loadResourcePath("font", font_name)
    font = love.graphics.newFont(path, size)
    _rescache[font_name] = font_group
    _rescache[font_name][size] = font
  end
  return font
end

return RES

