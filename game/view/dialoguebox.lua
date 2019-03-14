
local Class    = require "steaming.extra_libs.hump.class"
local VIEWDEFS = require 'view.definitions'
local RECT     = require "steaming.classes.primitives.rect"
local COLORS   = require 'domain.definitions.colors'
local FONT     = require 'view.helpers.font'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _font = FONT.get('Text', 20)

local DialogueBox = Class{
  __includes = { RECT }
}

--[[ PUBLIC METHODS ]]--

function DialogueBox:init(body, i, j)
  local x = (j+1)*_TILE_W
  local y = (i-1)*_TILE_H
  RECT.init(self, x, y, 100, 60)
  self.text = body:getDialogue()
end

function DialogueBox:draw()
  local g = love.graphics
  --Draw bg
  g.setColor(COLORS.HUD_BG)
  g.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(3)
  g.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)

  --Draw text
  g.setColor(COLORS.NEUTRAL)
  _font:set()
  g.print(self.text, self.pos.x + 10, self.pos.y)
end

return DialogueBox
