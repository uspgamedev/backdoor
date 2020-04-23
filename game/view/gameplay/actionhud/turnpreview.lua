
-- luacheck: globals love
local DB          = require 'database'
local RES         = require 'resources'
local COLORS      = require 'domain.definitions.colors'
local FONT        = require 'view.helpers.font'
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"
local vec2        = require 'cpml' .vec2

local ICON_W = 64
local ICON_H = 32
local ICON_PAD = 2
local ICON_MARGIN = 8
local ALPHA_SPEED = 2

local TurnPreview = Class{
  __includes = { ELEMENT }
}

local _MAX_TURNS = 6

TurnPreview.WIDTH = 140

function TurnPreview:init(player, handview, x, y)

  ELEMENT.init(self)

  self.player = player
  self.handview = handview
  self.position = vec2(x, y)
  self.alpha = 0

  self.title_font = FONT.get("Text", 24)
  self.text_font = FONT.get("Text", 18)
  self.turns = nil

end

function TurnPreview:disable()
  self.show = false
end

function TurnPreview:refresh()
  local seen = self.player:getVisibleBodies()
  local sector = self.player:getSector()
  if next(seen) then
    local turns_full = sector:previewTurns(_MAX_TURNS, false, function (actor)
      return actor == self.player or seen[actor:getBody():getId()]
    end)
    local turns_halved = sector:previewTurns(_MAX_TURNS, true, function (actor)
      return actor == self.player or seen[actor:getBody():getId()]
    end)
    if #turns_full > 0 and #turns_halved > 0 then
      self.turns = { full = turns_full, halved = turns_halved }
      self.show = true
    end
  else
    self.show = false
  end
end

function TurnPreview:update(dt)
  if self.show then
    self.alpha = math.min(self.alpha + ALPHA_SPEED*dt,1)
  else
    self.alpha = math.max(0, self.alpha - ALPHA_SPEED*dt)
  end
end

function TurnPreview:draw()
  if self.turns and self.alpha > 0 then
    local g = love.graphics
    g.push()
    g.translate(self.position:unpack())

    self.title_font:set()
    g.setColor(COLORS.NEUTRAL[1], COLORS.NEUTRAL[2], COLORS.NEUTRAL[3], self.alpha)
    g.print("NEXT TURNS", 0, 0)
    g.translate(0, 40)

    local which = self:_is_halved() and 'halved' or 'full'
    local skip = 0
    for i, actor in ipairs(self.turns[which]) do
      g.push()
      g.translate(0, (i - 1 + skip/2) * (ICON_H + ICON_MARGIN))

      if actor == self.player then
        self:draw_separator()
        g.translate(0, (ICON_H + ICON_MARGIN)/2)
        self:draw_icon(actor)
        skip = skip + 1
      else
        self:draw_icon(actor)
      end

      g.pop()

    end
    g.pop()
  end
end

function TurnPreview:_is_halved()
  local focused_card = self.handview:getFocusedCard()
  focused_card = focused_card and focused_card.card
  return focused_card and focused_card:isHalfExhaustion()
end

function TurnPreview:draw_icon(actor)
  local g = love.graphics

  --Draw actor icon
  g.setColor(COLORS.DARKER[1], COLORS.DARKER[2], COLORS.DARKER[3], self.alpha)
  g.rectangle('fill', 0, 0, ICON_W + 2*ICON_PAD, ICON_H + 2*ICON_PAD)
  g.setColor(COLORS.NEUTRAL[1], COLORS.NEUTRAL[2], COLORS.NEUTRAL[3], self.alpha)
  g.setLineWidth(2)
  g.rectangle('line', 0, 0, ICON_W + 2*ICON_PAD, ICON_H + 2*ICON_PAD)
  local appearance = DB.loadSpec(
    'appearance', actor:getBody():getAppearance()
  )
  local icon = RES.loadTexture(appearance.turn_icon)
  g.draw(icon, ICON_PAD, ICON_PAD)

  --Draw actor id
  if actor ~= self.player then
    self.text_font:set()
    local margin = 5
    local name = ("%s"):format(actor:getId())
    local y = (ICON_H + 2*ICON_PAD)/2 - self.text_font:getHeight()/2
    g.print(name, ICON_W + 2*ICON_PAD + margin, y)
  end
end

function TurnPreview:draw_separator()
  local g = love.graphics
  g.setColor(COLORS.NEUTRAL[1], COLORS.NEUTRAL[2], COLORS.NEUTRAL[3], self.alpha)
  self.text_font:set()
  g.print("-----------", 0, -ICON_MARGIN)
end

return TurnPreview
