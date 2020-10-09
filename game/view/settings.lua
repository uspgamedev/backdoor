
local COLORS = require 'domain.definitions.colors'
local PROFILE = require 'infra.profile'
local FONT = require 'view.helpers.font'
local Text = require 'view.helpers.text'
local Class = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local _ALPHA_SPEED = 5

local fmod = math.fmod
local sin = math.sin
local _PI = math.pi

local _font
local _controls_font

--Local methods forward declaration
local _renderControls

local SettingsView = Class{
  __includes = { ELEMENT }
}

local _getPreference = PROFILE.getPreference

function SettingsView:init(fields)
  ELEMENT.init(self)
  self.title = Text("SETTINGS", "Title", 32, {color = "NEUTRAL"})
  self.fields = fields
  self.focus = 1
  self.alpha = 0
  _controls_font = FONT.get("Text", 24)
  _font = FONT.get("Text", 20)
end

function SettingsView:update(dt)
  --Alpha always starts at 0, so we can always increased it
  self.alpha = math.min(self.alpha + _ALPHA_SPEED*dt, 1.0)
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

  _renderControls(g, self.alpha)

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
    local c = is_focused and COLORS.NEUTRAL or COLORS.HALF_VISIBLE
    g.setColor(c[1], c[2], c[3], self.alpha)
    g.print(field:gsub("[-]", " "):upper(), 0, -font_height)
    g.translate(0, font_height)

    -- line width offset
    g.translate(0, lw)

    -- trail
    g.setLineWidth(lw)
    c = is_focused and COLORS.EMPTY or COLORS.DARKER
    g.setColor(c[1], c[2], c[3], self.alpha)
    g.line(0, 0, width, 0)

    -- value progression
    c = is_focused and COLORS.NEUTRAL or COLORS.HALF_VISIBLE
    g.setColor(c[1], c[2], c[3], self.alpha)
    g.line(0, 0, percentage * width, 0)
    g.ellipse("fill", percentage * width, 0, height, height)

    g.pop()

  end
end

--Local fucntions
function _renderControls(g, alpha)
  g.push()
  g.translate(15, 676)

  _controls_font:set()
  local c = COLORS.NEUTRAL
  g.setColor(c[1], c[2], c[3], alpha)
  local text = "D to apply changes - S to cancel"
  g.print(text, 0, 0)

  g.pop()
end

return SettingsView
