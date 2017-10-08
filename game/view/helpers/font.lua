
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
    name_or_font.set()
    return name_or_font
  end
end

function FONT.get(name, size)
  local fnt = {}

  function fnt.getAttr(attr, ...)
    -- "attr" must be string in PascalCase!
    local self = _getFont(name, size)
    return self["get"..attr](self, ...)
  end

  function fnt.setAttr(attr, ...)
    -- "attr" must be string in PascalCase!
    local self = _getFont(name, size)
    return self["set"..attr](self, ...)
  end

  function fnt.getWidth(text)
    return _getFont(name, size):getWidth(text)
  end

  function fnt.getHeight()
    return _getFont(name, size):getHeight()
  end

  function fnt.getLineHeight()
    return _getFont(name, size):getLineHeight()
  end

  function fnt.setLineHeight(lh)
    return _getFont(name, size):setLineHeight(lh)
  end

  function fnt.set()
    FONT.set(name, size)
  end

  return fnt
end

return FONT

