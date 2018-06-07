
local RES        = require 'resources'
local FONT       = require 'view.helpers.font'
local ACTIONDEFS = require 'domain.definitions.action'
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS     = require 'domain.definitions.colors'
local Color      = require 'common.color'
local DEFS       = require 'domain.definitions'

local ACTOR_PANEL  = require 'view.actor.panel'
local ACTOR_HEADER = require 'view.actor.header'
local ACTOR_ATTR   = require 'view.actor.attr'

local math = require 'common.math'

local ActorView = Class{
  __includes = { ELEMENT }
}

local _TILE_W = 8
local _TILE_H = 8
local _FONT_NAME = "Text"
local _FONT_SIZE = 24
local _TILE_COLORS = {
  [SCHEMATICS.WALL]  = Color.fromInt {200, 128,  50},
  [SCHEMATICS.FLOOR] = Color.fromInt { 50, 128, 255},
  [SCHEMATICS.EXIT]  = Color.fromInt {200, 200,  40},
}

local _PANEL_MG = 24
local _PANEL_PD = 8
local _PANEL_WIDTH
local _PANEL_HEIGHT
local _PANEL_INNERWIDTH

local _WIDTH, _HEIGHT
local _exptext, _statstext
local _font
local _tile_mesh


local function _initGraphicValues()
  local g = love.graphics
  _WIDTH, _HEIGHT = g.getDimensions()
  _font = FONT.get(_FONT_NAME, _FONT_SIZE)
  _exptext = "Available EXP: %02d"
  _statstext = "STATS\nCOR: %d\nARC: %d\nANI: %d\nSPD: %d\nDEF: %dd%d"
  -- panel
  _PANEL_WIDTH = g.getWidth()/4
  _PANEL_HEIGHT = g.getHeight()
  _PANEL_INNERWIDTH = _PANEL_WIDTH - 2*_PANEL_PD - 2*_PANEL_MG
  ACTOR_PANEL.init(_PANEL_WIDTH, _PANEL_HEIGHT, _PANEL_MG)
  -- header
  ACTOR_HEADER.init(_PANEL_WIDTH, _PANEL_MG, _PANEL_PD)
  -- minimap
  _tile_mesh = g.newMesh(4, "fan", "dynamic")
  _tile_mesh:setVertex(1,       0,       0, 0, 0, 1, 1, 1)
  _tile_mesh:setVertex(2, _TILE_W,       0, 0, 0, 1, 1, 1)
  _tile_mesh:setVertex(3, _TILE_W, _TILE_H, 0, 0, 1, 1, 1)
  _tile_mesh:setVertex(4,       0, _TILE_H, 0, 0, 1, 1, 1)
  -- attributes
  ACTOR_ATTR.init(_PANEL_WIDTH)
end

function ActorView:init(route)

  ELEMENT.init(self)

  self.route = route
  self.actor = false

  _initGraphicValues()

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
  g.push()
  self:drawPanel(g)
  self:drawHP(g, actor)
  self:drawMiniMap(g, actor)
  self:drawHandCountDown(g, actor)
  self:drawAttributes(g, actor)
  g.pop()

  -- only visible when holding button
  if DEV then
    local fps_str = ("fps: %d"):format(love.timer.getFPS())
    g.setColor(1, 1, 1, 1)
    g.print(fps_str, g.getWidth()- 40 - _font:getWidth(fps_str),
            g.getHeight() - 24)
  end
end

function ActorView:drawPanel(g)
  g.setColor(COLORS.NEUTRAL)
  g.translate(3/4*g.getWidth(), 0)
  ACTOR_PANEL.draw(g, -_PANEL_MG*2, -_PANEL_MG)
end

function ActorView:drawHP(g, actor)
  local body = actor:getBody()
  local hp, pp = body:getHP(), actor:getPP()
  local max_hp, max_pp = body:getMaxHP(), DEFS.MAX_PP
  -- character name
  FONT.set("TextBold", 24)
  g.translate(_PANEL_MG, _PANEL_MG)
  g.setColor(COLORS.NEUTRAL)
  g.printf(actor:getTitle(), 0, -8, _PANEL_INNERWIDTH, "left")
  -- character hp & pp
  g.translate(0, 48)
  ACTOR_HEADER.drawBar(g, "HP", hp, max_hp, COLORS.SUCCESS, COLORS.NOTIFICATION)
  g.translate(0, 32)
  ACTOR_HEADER.drawBar(g, "PP", pp, max_pp, COLORS.PP, COLORS.PP)
end

function ActorView:drawHandCountDown(g, actor)
  -- draw hand countdown
  local handcountdown = actor:getHandCountdown()
  local current = self.hand_count_down or 0
  local y = 144
  current = current + (handcountdown - current) * 0.2
  if math.abs(current - handcountdown) < 1 then
    current = handcountdown
  end
  self.hand_count_down = current
  local handbar_percent = current / ACTIONDEFS.HAND_DURATION
  local handbar_width = 492
  local handbar_height = 12
  local font = FONT.get("Text", 18)
  local fh = font:getHeight()*font:getLineHeight()
  font:set()
  g.push()
  g.origin()
  g.translate(40, _HEIGHT - y + fh + handbar_height*2)
  g.setLineWidth(1)
  g.setColor(COLORS.BLACK)
  g.rectangle('line', 0, 0, handbar_width/2, handbar_height)
  g.setColor(COLORS.DARK)
  g.rectangle('fill', 0, 0, handbar_width/2, handbar_height)
  g.setColor(COLORS.WARNING)
  g.rectangle('fill', 0, 0, handbar_width/2 * handbar_percent, handbar_height)
  g.translate(0, -18)
  g.setColor(COLORS.BLACK)
  g.print("Hand Duration", 0, 0)
  g.translate(-1, -1)
  g.setColor(COLORS.NEUTRAL)
  g.print("Hand Duration", 0, 0)
  g.pop()
end

function ActorView:drawAttributes(g, actor)
  g.translate(_PANEL_MG*4/3, 2*_PANEL_MG + 192)
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

function ActorView:drawMiniMap(g, actor)
  local sector = self.route.getCurrentSector()
  local w, h = sector:getDimensions()
  local ai, aj = actor:getPos()
  local tiles = sector.tiles
  local zonename = sector:getZoneName()
  local nr, ng, nb = unpack(COLORS.NEUTRAL)
  local fov = actor:getFov(sector)
  g.translate(0, 48)
  g.push()
  g.setColor(nr, ng, nb, 1)
  g.translate(320, 20)
  g.printf(zonename,
           -_font:getWidth(zonename)/2, 0,
           _font:getWidth(zonename), "center")
  g.translate(- (w/2) * _TILE_W, _font:getHeight())
  for n=1,4 do
    _tile_mesh:setVertexAttribute(n, 3, 1, 1, 1, 1)
  end
  for i = 0, h-1 do
    for j = 0, w-1 do
      local ti, tj = i+1, j+1
      local tile = tiles[ti][tj]
      if tile and fov[i+1][j+1] then
        local x, y = j*_TILE_W, i*_TILE_H
        local cr,cg,cb = _TILE_COLORS[tile.type]:unpack()
        g.setColor(cr, cg, cb)
        g.draw(_tile_mesh, x, y)
        if ai == ti and aj == tj then
          g.setColor(1, 160/255, 40/255, 1)
          g.circle("fill", x+_TILE_W/2, y+_TILE_H/2, _TILE_W/2, _TILE_H/2)
        end
      end
    end
  end
  g.pop()
end

return ActorView

