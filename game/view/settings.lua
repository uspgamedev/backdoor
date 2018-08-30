
local COLORS = require 'domain.definitions.colors'
local PROFILE = require 'infra.profile'
local FONT = require 'view.helpers.font'
local Text = require 'view.helpers.text'

local fmod = math.fmod
local sin = math.sin

local _PI = math.pi

local _font

local SettingsView = Class{
  __includes = { ELEMENT }
}

local _getPreference = PROFILE.getPreference

function SettingsView:init(fields)
  ELEMENT.init(self)
  self.title = Text("SETTINGS", "Title", 32, {color = "NEUTRAL"})
  self.fields = fields
  self.focus = 1
  _font = FONT.get("Text", 20)
end

function SettingsView:setFocus(idx)
  self.focus = idx
end

function SettingsView:draw()
  local g = love.graphics
  local focus = self.focus
  local width = 256
  local height = 10
  local mx, my = 8, 8
  local font_height = 20
  local lw = 4
  local base_y = 256
  local x = 320
  -- draw one settings input type
  self.title:draw(x, base_y - 80)
  _font:set()
  for i, field in ipairs(self.fields) do
    local y = base_y + (i - 1) * (height + 4*my + font_height)
    local percentage = _getPreference(field) / 100
    local is_focused = (i == focus)
    g.push()
    g.translate(x, y)

    -- field name
    g.setColor(is_focused and COLORS.NEUTRAL or COLORS.HALF_VISIBLE)
    g.print(field:gsub("[-]", " "):upper(), 0, -font_height)
    g.translate(0, font_height)

    -- line width offset
    g.translate(0, lw)

    -- trail
    g.setLineWidth(lw)
    g.setColor(is_focused and COLORS.EMPTY or COLORS.DARKER)
    g.line(0, 0, width, 0)

    -- value progression
    g.setColor(is_focused and COLORS.NEUTRAL or COLORS.HALF_VISIBLE)
    g.line(0, 0, percentage * width, 0)
    g.ellipse("fill", percentage * width, 0, height, height)

    g.pop()
  end
end

return SettingsView

