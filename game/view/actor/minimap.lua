
local Color      = require 'common.color'
local Class      = require "steaming.extra_libs.hump.class"
local ELEMENT    = require "steaming.classes.primitives.element"
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS     = require 'domain.definitions.colors'
local FONT       = require 'view.helpers.font'

local min = math.min
local max = math.max

local _TILE_W = 8
local _TILE_H = 8
local _RAD_W = _TILE_W/2
local _RAD_H = _TILE_H/2
local _TILE_POLYGON = {
  0, 0,
  1, 0,
  1, 1,
  0, 1,
}
local _BODY_POLYGON = {
  0.5, 0,
  1, 0.5,
  0.5, 1,
  0, 0.5,
}

local _TILE_COLORS = {
  [SCHEMATICS.WALL]  = Color:new {0.3, 0.5, 0.9, 1},
  [SCHEMATICS.FLOOR] = Color:new {0.1, 0.3, 0.7, 1},
  [SCHEMATICS.EXIT]  = Color.fromInt {200, 200,  40, 255},
  [SCHEMATICS.ALTAR]  = Color.fromInt {30, 100,  240, 255},
}

local MINIMAP = Class{
  __includes = {ELEMENT}
}

function MINIMAP:init(route, x, y, width, height)
  ELEMENT.init(self)
  
  self.w, self.h = width, height
  self.x, self.y = x, y

  self.map = love.graphics.newCanvas(width, height)

  self.route = route
  self.actor = self.route:getControlledActor()

  self.font = FONT.get("Text", 20)
end

function MINIMAP:draw()
  local g = love.graphics
  local sector = self.route:getCurrentSector()
  local w, h = sector:getDimensions()
  local ai, aj = self.actor:getPos()
  local tiles = sector.tiles
  local zonename = sector:getZoneName()
  local nr, ng, nb = unpack(COLORS.NEUTRAL)
  local fov = self.actor:getFov(sector)

  g.push()
  g.translate(self.x, self.y)
  self.font:set()
  do
    g.setCanvas(self.map)
    g.push()
    g.origin()
    g.clear()
    g.setColor(COLORS.EMPTY)
    g.rectangle("fill", 0, 0, self.w, self.h)
    g.setColor(COLORS.NEUTRAL)
    local translation_x = -aj*_TILE_W + self.w/2
    local translation_y = -ai*_TILE_H + self.h/2
    g.translate(
      translation_x,
      translation_y
    )
    --]]--
    g.scale(_TILE_W, _TILE_H)
    for i = 0, h-1 do
      for j = 0, w-1 do
        local ti, tj = i+1, j+1
        local tile = tiles[ti][tj]
        local seen = fov[ti][tj]
        if tile and seen then
          local x, y = j, i
          g.push()
          g.setColor(_TILE_COLORS[tile.type])
          g.translate(x, y)
          g.polygon("fill", _TILE_POLYGON)
          if ai == ti and aj == tj then
            g.setColor(COLORS.NEUTRAL)
            g.polygon("fill", _BODY_POLYGON)
          elseif seen > 0 and sector:getBodyAt(ti, tj) then
            g.setColor(1, 0.4, 0.1)
            g.polygon("fill", _BODY_POLYGON)
          end
          g.pop()
        end
      end
    end
    g.pop()
    g.setCanvas()
  end
  g.setColor(COLORS.NEUTRAL)
  g.draw(self.map, 0, 0)
  g.push()
  g.translate(2, self.h-20)
  g.setColor(COLORS.BLACK)
  g.printf(zonename:upper(), 0, 0, self.w-8, "right")
  g.translate(-2, -2)
  g.setColor(COLORS.NEUTRAL)
  g.printf(zonename:upper(), 0, 0, self.w-8, "right")
  g.pop()
  g.pop()
end

return MINIMAP
