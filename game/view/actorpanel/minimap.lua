
local Node        = require 'view.node'
local Text        = require 'view.helpers.text'
local Color       = require 'common.color'
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'
local Class       = require "steaming.extra_libs.hump.class"

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

local MiniMap = Class({ __includes = { Node } })

function MiniMap:init(actor, x, y, w, h)
  Node.init(self)
  self:setPosition(x, y)
  self.width = w
  self.height = h
  self.actor = actor
  self.sector = actor:getSector()
  self.map_canvas = love.graphics.newCanvas(w, h)
  self.zonename = Text(self.sector:getZoneName():upper(), "Text", 20,
                       { width = w-8, align = 'right', dropshadow = true })
end

local _renderTiles

function MiniMap:process(dt)
  self.sector = self.actor:getSector()
end

function MiniMap:render(g)
  _renderTiles(g, self.map_canvas, self.sector, self.actor)
  g.setColor(COLORS.NEUTRAL)
  g.draw(self.map_canvas, 0, 0)
  self.zonename:draw(2, self.height-20)
end

function _renderTiles(g, map_canvas, sector, actor)
  local w, h = sector:getDimensions()
  local ai, aj = actor:getPos()
  local tiles = sector.tiles
  local nr, ng, nb = unpack(COLORS.NEUTRAL)
  local fov = actor:getFov(sector)
  local canvas_width, canvas_height = map_canvas:getDimensions()
  g.setCanvas(map_canvas)
  g.push()
  g.origin()
  g.clear()
  g.setColor(COLORS.EMPTY)
  g.rectangle("fill", 0, 0, canvas_width, canvas_height)
  g.setColor(COLORS.NEUTRAL)
  local translation_x = -aj*_TILE_W + canvas_width/2
  local translation_y = -ai*_TILE_H + canvas_height/2
  g.translate(
    translation_x,
    translation_y
  )
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

return MiniMap

