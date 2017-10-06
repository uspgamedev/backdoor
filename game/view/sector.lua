
local DB          = require 'database'
local RES         = require 'resources'
local HSV         = require 'common.color'.hsv
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'
local DIR         = require 'domain.definitions.dir'
local Queue       = require "lux.common.Queue"

local TILE_W = 80
local TILE_H = 80
local HALF_W = 10
local HALF_H = 6

local HEALTHBAR_WIDTH = 64
local HEALTHBAR_HEIGHT = 8

local _texture
local _tile_offset
local _tile_quads
local _batch
local _cursor_sprite
local _isInCone

local Cursor

local SectorView = Class{
  __includes = { ELEMENT }
}

local function _moveCamera(target)
  local x, y = CAM:position()
  local i, j = target:getPos()
  local tx, ty = (j-0.5)*TILE_W, (i-0.5)*TILE_H
  local smooth = 1/12
  CAM:move((tx - x)*smooth,(ty - y)*smooth)
end

local function _initDrawables()

  -- FIXME: Tiles are not gotten from DB right now
  local g = love.graphics

  _texture = RES.loadTexture("bare-tiles")
  _texture:setFilter("nearest", "nearest")
  local tw, th = _texture:getDimensions()

  _tile_offset = {
    [SCHEMATICS.FLOOR] = {},
    [SCHEMATICS.EXIT]  = {},
    [SCHEMATICS.WALL]  = {0, 60},
  }

  _tile_quads = {
    [SCHEMATICS.FLOOR] = g.newQuad(0, 0, TILE_W, TILE_H, tw, th),
    [SCHEMATICS.EXIT] = g.newQuad(80, 0, TILE_W, TILE_H, tw, th),
    [SCHEMATICS.WALL] = g.newQuad(240, 0, TILE_W, 140, tw, th),
    shade = g.newQuad(160, 0, TILE_W, TILE_H, tw, th),
  }

  _batch = g.newSpriteBatch(_texture, 512, "stream")
  --FIXME: Get tile info from resource cache or something

end

function SectorView:init(route)

  ELEMENT.init(self)

  self.target = nil
  self.cursor = nil
  self.vfx = {
    offset = {}
  }

  self.route = route
  self.body_sprites = {}

  _initDrawables()

end

function SectorView:hasPendingVFX()
  return not Util.tableEmpty(self.vfx.offset)
end

function SectorView:lookAt(target)
  self.target = target
end

function SectorView:addVFX(extra)
  if extra.type == 'body_moved' then
    local body, i, j = extra.body, unpack(extra.origin)
    local i0, j0 = body:getPos()
    local offset = {i - i0, j - j0}
    self.vfx.offset[body] = offset
    self:addTimer(nil, MAIN_TIMER, "tween", 0.05, offset, {0, 0}, "in-out-quad",
                  function() self.vfx.offset[body] = nil end)
  end
end

function SectorView:draw()
  local sector = self.route.getCurrentSector()
  local g = love.graphics
  if self.target then
    _moveCamera(self.target)
  end
  local cx, cy = CAM:position()
  cx = cx / TILE_W
  cy = cy / TILE_H
  g.setBackgroundColor(75, 78, 60, 255)
  g.setColor(COLORS.NEUTRAL)
  g.push()
  for i = 0, sector.h-1 do
    local draw_bodies = {}
    local highlights = {}
    _batch:clear()
    for j = 0, sector.w-1 do
      if j >= cx - HALF_W and j <= cx + HALF_W and
        i >= cy - HALF_H and i <= cy + HALF_H then
        local tile = sector.tiles[i+1][j+1]
        if tile then
          -- Add tiles to spritebatch
          local body = sector.bodies[i+1][j+1]
          local x = j*TILE_W
          if tile.type ~= SCHEMATICS.WALL then
            if self.cursor and self.cursor.range_checker(i+1, j+1) then
              table.insert(highlights, {x, 0, TILE_W, TILE_H, {100, 200, 200}})
            end
            if self.cursor and self.cursor.validator(i+1, j+1) then
              table.insert(highlights, {x, 0, TILE_W, TILE_H, {200, 200, 100}})
            end
            if body then
              table.insert(draw_bodies, {body, x, 0})
            end
          end
          _batch:add(_tile_quads[tile.type], x, 0,
                    0, 1, 1, unpack(_tile_offset[tile.type]))
          _batch:add(_tile_quads.shade, x, TILE_H)
        end
      end
    end

    -- Actually Draw tiles
    g.setColor(COLORS.NEUTRAL)
    g.draw(_batch, 0, 0)

    -- Draw highlights
    for _, highlight in ipairs(highlights) do
      local x,y,w,h,color = unpack(highlight)
      color[4] = 100
      g.setColor(color)
      g.rectangle('fill', x, y, w, h)
    end

    --Draw Cursor, if it exists
    if self.cursor then
      local c_i, c_j = self:getCursorPos()
      if c_i == i+1 then
        local x = (c_j-1)*TILE_W
        _cursor_sprite = _cursor_sprite or RES.loadSprite("cursor")
        g.push()
        g.translate(x, 0)
        if self.cursor.validator(c_i, c_j) then
          g.setColor(COLORS.NEUTRAL)
        else
          g.setColor(255, 50, 50)
        end
        _cursor_sprite(0, 0)
        g.pop()
      end
    end

    -- Draw dem bodies
    for _, bodyinfo in ipairs(draw_bodies) do
      local body, x, y = unpack(bodyinfo)
      local id = body:getId()
      local draw_sprite = self.body_sprites[id] if not draw_sprite then
        local idle = DB.loadSpec('appearance', body:getAppearance()).idle
        draw_sprite = RES.loadSprite(idle)
        self.body_sprites[id] = draw_sprite
      end
      local di, dj = unpack(self.vfx.offset[body] or {0,0})
      local dx, dy = dj*TILE_W, di*TILE_H
      x, y = x+dx, y+dy
      g.push()
      g.setColor(COLORS.NEUTRAL)
      draw_sprite(x, dy)
      g.translate(x, dy)
      local hp_percent = body:getHP()/body:getMaxHP()
      g.setColor(0, 20, 0)
      g.rectangle("fill", (TILE_W - HEALTHBAR_WIDTH)/2, -48, HEALTHBAR_WIDTH,
                  HEALTHBAR_HEIGHT)
      local hsvcol = { 0 + 100*hp_percent, 240, 150 - 50*hp_percent }
      g.setColor(HSV(unpack(hsvcol)))
      g.rectangle("fill", (TILE_W - HEALTHBAR_WIDTH)/2, -48,
                  hp_percent*HEALTHBAR_WIDTH, HEALTHBAR_HEIGHT)
      g.pop()
    end
    g.translate(0, TILE_H)
  end
  g.pop()
end

--CURSOR FUNCTIONS

function SectorView:newCursor(i,j,validator,range_checker)
  i, j = i or 1, j or 1
  self.cursor = Cursor(i,j,validator,range_checker)
end

function SectorView:removeCursor()
  self.cursor = nil
end

function SectorView:getCursorPos()
  if not self.cursor then return end

  return self.cursor:getPos()
end

function SectorView:setCursorPos(i,j)
  if not self.cursor then return end

  self.cursor.i = i
  self.cursor.j = j
end

--Function checks if a target position is inside "target cone" given desired direction {di,dj}
function _isInCone(origin_i, origin_j, target_i, target_j, dir)
  local i = target_i - origin_i
  local j = target_j - origin_j

  if     dir == "up" then   --UP
    return j >= i and j <= -i
  elseif dir == "right" then   --RIGHT
    return i >= -j and i <= j
  elseif dir == "down" then   --DOWN
    return j <= i and j >= -i
  elseif dir == "left" then     --LEFT
    return i <= -j and i >= j
  elseif dir == "upright" then   --UPRIGHT
    return i <= 0 and j >= 0
  elseif dir == "downright" then   --DOWNRIGHT
    return i >= 0 and j >= 0
  elseif dir == "downleft" then   --DOWNLEFT
    return i >= 0 and j <= 0
  elseif dir == "upleft" then   --UPLEFT
    return i <= 0 and j <= 0
  else
    return error(("Not valid direction for cone function: %s"):format(dir))
  end

end

function SectorView:moveCursor(di, dj)
  if not self.cursor then return end

  local sector = self.route.getCurrentSector()
  local queue = Queue(128)
  local chosen = false
  local sector_map = {}

  if not sector:isInside(self.cursor.i + di, self.cursor.j + dj) then
    return
  end

  -- get direction's name
  local dirname
  for _,dir in ipairs(DIR) do
    local i, j = unpack(DIR[dir])
    dirname = dir
    if di == i and dj == j then break end
  end

  --Reset all sector position to "not-seen"
  for i = 1, sector.h do
    sector_map[i] = {}
    for j = 1, sector.w do
      sector_map[i][j] = false
    end
  end

  --Initialize queue with first valid position
  sector_map[self.cursor.i][self.cursor.j] = true
  queue.push({self.cursor.i + di, self.cursor.j + dj})

  --Start "custom-bfs"
  while not queue.isEmpty() do
    if chosen then break end
    local pos = queue.pop()

    --Else add all other valid positions to the queue
    for _,dir in ipairs(DIR) do
      local i, j = unpack(DIR[dir])
      local target_pos = {pos[1] + i, pos[2] + j}
      --Check if position is inside sector
      if sector:isInside(unpack(target_pos))
         --Check if position hasn't been "seen"
         and not sector_map[target_pos[1]][target_pos[2]]
         --Check if position is inside desired cone
         and _isInCone(self.cursor.i, self.cursor.j,
                       target_pos[1], target_pos[2], dirname)
         -- Check if position is within range
         and self.cursor.range_checker(unpack(target_pos)) then

        -- if it's a valid target use it!
        if self.cursor.validator(unpack(target_pos)) then
          chosen = target_pos
          break
        end

        --Mark position as "seen"
        sector_map[target_pos[1]][target_pos[2]] = true
        queue.push(target_pos)
      end
    end
    pos = nil
  end

  if chosen then
    self.cursor.i = chosen[1]
    self.cursor.j = chosen[2]
  end

end

function SectorView:lookAtCursor()
  if self.cursor then
    self:lookAt(self.cursor)
  end
end

--CURSOR CLASS--

Cursor = Class{
  __includes = { ELEMENT }
}

function Cursor:init(i, j, validator, range_checker)
  self.i = i
  self.j = j

  self.validator = validator
  self.range_checker = range_checker
end

function Cursor:getPos()
  return self.i, self.j
end

return SectorView
