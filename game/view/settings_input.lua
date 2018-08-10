
local SettingsItemView = Class{
  __includes = { ELEMENT }
}

function Settings:init()
  ELEMENT.init(self)
end

function SettingsItemView:draw()
  local g = love.graphics
  -- draw one settings input type
end

return SettingsItemView

