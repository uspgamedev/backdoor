
local FONT        = require 'view.helpers.font'
local VIEW_COLORS = require 'view.definitions.colors'

local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"

local InfoPanel = Class{
  __includes = { ELEMENT }
}

local _WIDTH = 240
local _HEADER_HEIGHT = 48
local _HEIGHT = 440
local _CORNER = 24
local _HPAD = 16
local _VPAD = 8

local _TWEEN = 'infopanel_tween'

local _BODY_SHAPE = {
  0, _HEADER_HEIGHT,
  _WIDTH, _HEADER_HEIGHT,
  _WIDTH, _HEIGHT - _CORNER,
  _WIDTH - _CORNER, _HEIGHT,
  0, _HEIGHT,
}

local _HEADER_SHAPE = {
  _CORNER, 0,
  _WIDTH, 0,
  _WIDTH, _HEADER_HEIGHT,
  0, _HEADER_HEIGHT,
  0, _CORNER,
}

function InfoPanel:init(position, handview)

  ELEMENT.init(self)

  self.handview = handview
  self.position = position:clone()
  self.title = "TITLE"
  self.title_font = FONT.get('Title', 20)
  self.text_font = FONT.get('Text', 18)
  self.text = "> This is a test"
  self.modulate = VIEW_COLORS.IDENTITY:clone()
  self.modulate[4] = 0.0

end

function InfoPanel:setText(text)
  text = text:gsub("([^\n])[\n]([^\n])", "%1 %2")
  --text = text:gsub("\n\n", "\n")
  self.text = text
end

function InfoPanel:hide()
  local timer = MAIN_TIMER -- luacheck: globals MAIN_TIMER
  local duration = self.modulate[4] / 2
  self:removeTimer(_TWEEN)
  self:addTimer(_TWEEN, timer, 'tween', duration, self.modulate,
                { [4] = 0 }, 'out-linear')
end

function InfoPanel:show()
  local timer = MAIN_TIMER -- luacheck: globals MAIN_TIMER
  local duration = math.max(0, 1.0 - self.modulate[4]) / 2
  self:removeTimer(_TWEEN)
  self:addTimer(_TWEEN, timer, 'tween', duration, self.modulate,
                { [4] = 1 }, 'out-linear')
end

function InfoPanel:isVisible()
  return not self.invisible
end

function InfoPanel:update(_)
  self.invisible = self.modulate[4] <= 0
  self.modulate[4] = math.min(math.max(self.modulate[4], 0), 1)
  if self.handview:isActive() then
    local player = self.handview.route.getPlayerActor()
    local card = self.handview:getFocusedCard().card
    local text = card:getEffect(player)
    self.title = card:getName()
    self:setText(text)
  end
end

function InfoPanel:draw()
  local g = love.graphics -- luacheck: globals love
  g.push()
  g.translate(self.position:unpack())
  -- HEADER
  g.setColor(VIEW_COLORS.BRIGHT * self.modulate)
  g.polygon('fill', _HEADER_SHAPE)
  g.setColor(VIEW_COLORS.DARK * self.modulate)
  self.title_font:set()
  g.printf(self.title:upper(), _HPAD, _VPAD, _WIDTH - 2*_HPAD, 'center')
  -- BODY
  g.setColor(VIEW_COLORS.DARK:withAlpha(0.8) * self.modulate)
  g.polygon('fill', _BODY_SHAPE)
  g.setColor(VIEW_COLORS.BRIGHT * self.modulate)
  g.setLineWidth(4)
  self.text_font:set()
  g.printf(self.text, _HPAD, _HEADER_HEIGHT + _HPAD, _WIDTH - 2*_HPAD, 'left')
  g.pop()
end

return InfoPanel

