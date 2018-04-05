
local RES        = require 'resources'
local FONT       = require 'view.helpers.font'
local ACTIONDEFS = require 'domain.definitions.action'
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS     = require 'domain.definitions.colors'
local Color      = require 'common.color'

local math = require 'common.math'

local ActorView = Class{
  __includes = { ELEMENT }
}

local _TILE_W = 8
local _TILE_H = 8
local _FONT_NAME = "Text"
local _FONT_SIZE = 24
local _MINIMAP_ALPHA = 180 / 255

local _initialized = false
local _exptext, _statstext, _depthtext, _buffertext
local _width, _height, _font
local _display_handle
local _tile_colors = {}
local _tile_mesh


local function _initGraphicValues()
  local g = love.graphics
  _width, _height = g.getDimensions()
  _font = FONT.get(_FONT_NAME, _FONT_SIZE)
  _exptext = "EXP: %d"
  _statstext = "STATS\nCOR: %d\nARC: %d\nANI: %d\nSPD: %d\nDEF: %dd%d"
  _actor_text = "HP: %d/%d"
  _depthtext = "DEPTH: %d"
  _buffertext = "%d cards in buffer\n%d in backbuffer\n%d in hand\n%d in total"
  _display_handle = "toggle_show_hide_actorview"
  _tile_colors = {
    [SCHEMATICS.WALL] = Color.fromInt {200, 128, 50},
    [SCHEMATICS.FLOOR] = Color.fromInt {50, 128, 255},
    [SCHEMATICS.EXIT] = Color.fromInt {200, 200, 40},
  }
  _tile_mesh = g.newMesh(4, "fan", "dynamic")
  _tile_mesh:setVertex(1, 0, 0, 0, 0, 1, 1, 1, _MINIMAP_ALPHA)
  _tile_mesh:setVertex(2, _TILE_W, 0, 0, 0, 1, 1, 1, _MINIMAP_ALPHA)
  _tile_mesh:setVertex(3, _TILE_W, _TILE_H, 0, 0, 1, 1, 1, _MINIMAP_ALPHA)
  _tile_mesh:setVertex(4, 0, _TILE_H, 0, 0, 1, 1, 1, _MINIMAP_ALPHA)
  _initialized = true
end

function ActorView:init(route)

  ELEMENT.init(self)

  self.route = route
  self.actor = false
  self.alpha = 0

  if not _initialized then _initGraphicValues() end

end

function ActorView:show()
  self:removeTimer(_display_handle, MAIN_TIMER)
  self:addTimer(_display_handle, MAIN_TIMER, "tween",
                .2, self, { alpha = 1 }, "out-quad")
end

function ActorView:hide()
  self:removeTimer(_display_handle, MAIN_TIMER)
  self:addTimer(_display_handle, MAIN_TIMER, "tween",
                .2, self, { alpha = 0 }, "out-quad")
end

function ActorView:loadActor()
  local newactor = self.route.getControlledActor()
  if self.actor ~= newactor and newactor then
    self.actor = newactor
  end
  return self.actor
end

function ActorView:draw()
  local g = love.graphics
  local actor = self:loadActor()
  if not actor then return end
  local cr,cg,cb = unpack(COLORS.NEUTRAL)

  _font:set()
  _font:setLineHeight(1)

  -- always visible
  self:drawImportantHUD(g, actor)

  -- only visible when holding button
  g.setColor(cr, cg, cb, self.alpha)
  if self.alpha > 0 then
    self:drawMiniMap(g, actor)
    self:drawHP(g, actor)
    self:drawAttributes(g, actor)
    self:drawBuffers(g, actor)
    self:drawDepth(g)
  end
end

function ActorView:drawImportantHUD(g, actor)
  local pptext = ("%d/%d PP"):format(actor:getPP(), ACTIONDEFS.NEW_HAND_COST)
  local xptext = _exptext:format(actor:getExp())
  local pcktext = ("%d PACK(S) UNOPENED!"):format(actor:getPrizePackCount())
  local fh = _font:getHeight()
  local normal_y = 100
  local unfocus_y = 440
  local spd = 15
  local dt = love.timer.getDelta()
  local y = self.importanthud_y or normal_y

  if self.onhandview then
    y = math.round(y + (unfocus_y - y) * spd * dt)
    if math.abs(unfocus_y-y) < 1 then y = unfocus_y end
  else
    y = math.round(y + (normal_y - y) * spd * dt)
    if math.abs(normal_y-y) < 1 then y = normal_y end
  end
  self.importanthud_y = y

  g.push()
  g.setColor(COLORS.DARK)
  g.print(pptext, 40, _height-y-fh*2)
  g.print(xptext, 40, _height-y-fh)
  if actor:getPrizePackCount() > 0 then
    g.print(pcktext, 40, _height-y)
  end
  g.translate(-2, -2)
  if actor:getPP() >= ACTIONDEFS.NEW_HAND_COST then
    g.setColor(COLORS.SUCCESS)
  else
    g.setColor(COLORS.WARNING)
  end
  g.print(pptext, 40, _height-y-fh*2)
  g.setColor(COLORS.NEUTRAL)
  g.print(xptext, 40, _height-y-fh)
  if actor:getPrizePackCount() > 0 then
    g.setColor(COLORS.NOTIFICATION)
    g.print(pcktext, 40, _height-y)
  end
  g.pop()
end

function ActorView:drawHP(g, actor)
  g.push()
  local cr, cg, cb = unpack(COLORS.NEUTRAL)
  local body = actor:getBody()
  local hp, max_hp = body:getHP(), body:getMaxHP()
  local str = _actor_text:format(hp, max_hp)
  local w = _font:getWidth(str) + _font:getHeight()
  g.translate(_width/2 - w/2, _height/2 + 20)
  g.setColor(0, 0, 0, self.alpha)
  g.printf(str, 0, 0, w, "center")
  g.translate(-2, -2)
  g.setColor(cr, cg, cb, self.alpha)
  g.printf(str, 0, 0, w, "center")
  g.pop()
end

function ActorView:drawAttributes(g, actor)
  g.push()
  local cor = actor:getCOR()
  local arc = actor:getARC()
  local ani = actor:getANI()
  local spd = actor:getSPD()
  local def = actor:getBody():getDEF()
  local base_def = actor:getBody():getBaseDEF()
  g.translate(40, 40)
  g.print(_statstext:format(cor, arc, ani, spd, def, base_def))
  g.pop()
end

function ActorView:drawDepth(g)
  local sector = self.route.getCurrentSector()
  local str = _depthtext:format(sector:getDepth())
  local w = _font:getWidth(str)
  g.push()
  g.translate(_width - 40 - w, 40)
  g.printf(str, 0, 0, w, "right")
  g.pop()
end

function ActorView:drawBuffers(g, actor)
  g.push()
  g.translate(40, 40 + 8.5*_font:getHeight())
  local buffer_size = actor:getBufferSize()
  local back_buffer_size = actor:getBackBufferSize()
  local hand_size = actor:getHandSize()
  local str = _buffertext:format(buffer_size, back_buffer_size, hand_size,
                                 buffer_size + back_buffer_size + hand_size)
  g.print(str, 0, 0)
  g.pop()
end

function ActorView:drawMiniMap(g, actor)
  local sector = self.route.getCurrentSector()
  local w, h = sector:getDimensions()
  local ai, aj = actor:getPos()
  local tiles = sector.tiles
  local sectorname = sector:getSpecName()
  local nr, ng, nb = unpack(COLORS.NEUTRAL)
  local fov = actor:getFov(sector)
  g.push()
  g.setColor(nr, ng, nb, self.alpha)
  g.translate(320, 20)
  g.printf(sectorname,
           -_font:getWidth(sectorname)/2, 0,
           _font:getWidth(sectorname), "center")
  g.translate(- (w/2) * _TILE_W, _font:getHeight())
  for n=1,4 do
    _tile_mesh:setVertexAttribute(n, 3, 1, 1, 1, _MINIMAP_ALPHA*self.alpha)
  end
  for i = 0, h-1 do
    for j = 0, w-1 do
      local ti, tj = i+1, j+1
      local tile = tiles[ti][tj]
      if tile and fov[i+1][j+1] then
        local x, y = j*_TILE_W, i*_TILE_H
        local cr,cg,cb = _tile_colors[tile.type]:unpack()
        g.setColor(cr, cg, cb)
        g.draw(_tile_mesh, x, y)
        if ai == ti and aj == tj then
          g.setColor(1, 160/255, 40/255, self.alpha)
          g.circle("fill", x+_TILE_W/2, y+_TILE_H/2, _TILE_W/2, _TILE_H/2)
        end
      end
    end
  end
  g.pop()
end

return ActorView

