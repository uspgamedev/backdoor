
local DB          = require 'database'
local RES         = require 'resources'
local HSV         = require 'common.color'.hsv
local math        = require 'common.math'
local CAM         = require 'common.camera'
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'
local DIR         = require 'domain.definitions.dir'
local FONT        = require 'view.helpers.font'
local Queue       = require "lux.common.Queue"

local _TILE_W = 80
local _TILE_H = 60
local _HALF_W = 10
local _HALF_H = 10

local _HEALTHBAR_WIDTH = 56
local _HEALTHBAR_HEIGHT = 4

local _texture
local _tile_offset
local _tile_quads
local _flat_batch
local _tall_batch
local _tileset
local _cursor_sprite
local _font

local _isInCone

local Cursor

local SectorView = Class{
  __includes = { ELEMENT }
}

local function _moveCamera(target)
  local i, j = target:getPos()
  local tx, ty = (j-0.5)*_TILE_W, (i-0.5)*_TILE_H
  CAM:lockPosition(tx, ty)
end


local function _isInFrame(i, j)
  local cx, cy = CAM:position()
  cx = cx / _TILE_W
  cy = cy / _TILE_H
  return     j >= cx - _HALF_W
         and j <= cx + _HALF_W
         and i >= cy - _HALF_H
         and i <= cy + _HALF_H
end

function SectorView:init(route)

  ELEMENT.init(self)

  self.target = nil
  self.cursor = nil
  self.ray_dir = nil
  self.ray_body_block = false
  self.vfx = {
    offset = {}
  }

  self.fov = nil --Fov to apply on the sector

  self.route = route
  self.body_sprites = {}
  self.sector = false

  _font = _font or FONT.get("Text", 16)

end

function SectorView:initSector(sector)
  if sector and sector ~= self.sector then
    local g = love.graphics
    self.sector = sector

    _tileset = RES.loadTileSet(sector:getTileSet())
    _texture = RES.loadTexture(_tileset.texture)

    _tile_offset = _tileset.offsets
    _tile_quads = _tileset.quads

    _flat_batch = g.newSpriteBatch(_texture, 512, "stream")
    _tall_batch = g.newSpriteBatch(_texture, 512, "stream")
    --FIXME: Get tile info from resource cache or something
  end
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

function SectorView:updateFov(actor)
  self.fov = actor.fov
end

function SectorView:setRayDir(dir, body_block)
  self.ray_dir = dir
  self.ray_body_block = body_block
end

function SectorView:draw()
  local g = love.graphics
  local sector = self.route.getCurrentSector()
  self:initSector(sector)
  if not self.sector then return end
  if self.target then
    _moveCamera(self.target)
  end
  g.setBackgroundColor(75, 78, 60, 255)
  g.setColor(COLORS.NEUTRAL)
  g.push()

  -- draw flat tiles
  _flat_batch:clear()
  for i = 0, sector.h-1 do
    for j = 0, sector.w-1 do
      local tile = sector.tiles[i+1][j+1]
      if _isInFrame(i, j) and tile then
        local tile_type = (tile.type == SCHEMATICS.WALL)
                          and SCHEMATICS.FLOOR or tile.type
        local x, y = j*_TILE_W, i*_TILE_H
        _flat_batch:add(_tile_quads[tile_type], x, y,
                        0, 1, 1, unpack(_tile_offset[tile.type]))
      end
    end
  end
  g.draw(_flat_batch, 0, 0)

  if self.fov then
    for i = 1, sector.h do
      for j = 1, sector.w do
        if not self.fov[i][j] then --Never seen
          local alpha = 255
          local x, y = (j-1)*_TILE_W, (i-1)*_TILE_H
          g.setColor(0,0,0,alpha)
          g.rectangle("fill", x, y, _TILE_W, _TILE_H)
        elseif self.fov[i][j] == 0 then --Seen once but invisible now
          local alpha = 140
          local x, y = (j-1)*_TILE_W, (i-1)*_TILE_H
          g.setColor(0,0,0,alpha)
          g.rectangle("fill", x, y, _TILE_W, _TILE_H)
        end
      end
    end
  end

  local rays = {}
  for i=1,sector.h do
    rays[i] = {}
    for j=1,sector.w do
      rays[i][j] = false
    end
  end

  if self.ray_dir and self.target then
    local dir = self.ray_dir
    local i, j = self.target:getPos()
    local check
    if self.ray_body_block then
      check = sector.isValid
    else
      check = sector.isWalkable
    end
    repeat
      rays[i][j] = true
      i = i + dir[1]
      j = j + dir[2]
    until not check(sector, i, j) or not self.fov[i][j]
  end

  -- draw tall things
  g.push()
  local all_bodies = {}
  local named
  for i = 0, sector.h-1 do
    local draw_bodies = {}
    local highlights = {}
    _tall_batch:clear()
    for j = 0, sector.w-1 do
      local tile = sector.tiles[i+1][j+1]
      if _isInFrame(i, j) and tile then
        -- Add tiles to spritebatch
        local body = sector.bodies[i+1][j+1]
        local x = j*_TILE_W
        if tile.type == SCHEMATICS.WALL then
          if self.fov and not self.fov[i+1][j+1] then
            _tall_batch:setColor(0, 0, 0, 255)
          elseif self.fov and self.fov[i+1][j+1] == 0 then
            _tall_batch:setColor(100, 100, 100, 255)
          else
            _tall_batch:setColor(255, 255, 255, 255)
          end
          _tall_batch:add(_tile_quads[tile.type], x, 0,
                          0, 1, 1, unpack(_tile_offset[tile.type]))
        elseif self.cursor then
          local current_body = self.route.getControlledActor():getBody()
          if not self.fov or (self.fov[i+1][j+1] and
                              self.fov[i+1][j+1] > 0)
                          or body == current_body then
            if self.cursor.range_checker(i+1, j+1) then
              table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                         {100, 200, 200, 100} })
            end
            if self.cursor.validator(i+1, j+1) then
              table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                         {100, 200, 100, 100} })
            end
            local ci, cj = self.cursor:getPos()
            local size   = self.cursor.aoe_hint or 1
            local abs    = math.abs
            if size and tile.type == SCHEMATICS.FLOOR
                    and abs(i+1 - ci) < size and abs(j+1 - cj) < size then
              table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                         {200, 100, 100, 100} })
            end
          end
        elseif self.ray_dir and rays[i+1][j+1] then
          table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                     {200, 100, 100, 100} })
        end
        if body then
          table.insert(draw_bodies, {body, x, 0})
          table.insert(all_bodies, body)
        end
      end
    end

    -- Actually Draw tiles
    g.setColor(COLORS.NEUTRAL)
    g.draw(_tall_batch, 0, 0)

    -- Draw highlights
    for _, highlight in ipairs(highlights) do
      local x,y,w,h,color = unpack(highlight)
      g.setColor(color)
      g.rectangle('fill', x, y, w, h)
    end

    --Draw Cursor, if it exists
    if self.cursor then
      local c_i, c_j = self:getCursorPos()
      if c_i == i+1 then
        local x = (c_j-1)*_TILE_W
        _cursor_sprite = _cursor_sprite or RES.loadSprite("cursor")
        g.push()
        g.translate(x, 0)
        if self.cursor.validator(c_i, c_j) then
          -- NAME
          local body = sector:getBodyAt(c_i, c_j)
          if body then
            named = body
          end
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
      local i,j = body:getPos()

      --Draw only bodies if player is seeing them
      if not self.fov or (self.fov[i][j] and self.fov[i][j] ~= 0) then

        local id = body:getId()
        local draw_sprite = self.body_sprites[id]
        if not draw_sprite then
          local idle = DB.loadSpec('appearance', body:getAppearance()).idle
          draw_sprite = RES.loadSprite(idle)
          self.body_sprites[id] = draw_sprite
        end
        local di, dj = unpack(self.vfx.offset[body] or {0,0})
        local dx, dy = dj*_TILE_W, di*_TILE_H
        x, y = x+dx, y+dy
        g.setColor(COLORS.NEUTRAL)
        draw_sprite(x, dy)

      end
    end


    g.translate(0, _TILE_H)
  end
  g.pop()

  -- HP, above everything
  for _,body in ipairs(all_bodies) do
    local i, j = body:getPos()
    if not self.fov or (self.fov[i][j] and self.fov[i][j] ~= 0) then
      local x, y = (j-1)*_TILE_W, (i-1)*_TILE_H
      local hp_percent = body:getHP()/body:getMaxHP()
      local hsvcol = { 0 + 100*hp_percent, 240, 200 - 50*hp_percent }
      local cr, cg, cb = HSV(unpack(hsvcol))
      g.push()
      g.translate(x, y)
      g.setColor(0, 20, 0, 200)
      g.rectangle("fill", (_TILE_W + _HEALTHBAR_WIDTH)/2, _TILE_H-20,
                  (hp_percent-1)*_HEALTHBAR_WIDTH, _HEALTHBAR_HEIGHT)
      g.setColor(cr, cg, cb, 200)
      g.rectangle("fill", (_TILE_W - _HEALTHBAR_WIDTH)/2, _TILE_H-20,
                  hp_percent*_HEALTHBAR_WIDTH, _HEALTHBAR_HEIGHT)

      -- NAME
      if named == body then
        local name = body:getSpec('name')
        local actor = sector:getActorFromBody(body)
        if actor then
          name = ("%s %s"):format(actor:getSpec('name'), name)
        end
        _font.set()
        _font:setLineHeight(.8)
        g.setColor(COLORS.NEUTRAL)
        g.printf(name, -0.5*_TILE_W, _TILE_H-5, 2*_TILE_W, "center")
      end
      g.pop()
    end
  end

  g.pop()
end

--CURSOR FUNCTIONS

function SectorView:newCursor(i, j, aoe_hint, validator, range_checker)
  i, j = i or 1, j or 1
  self.cursor = Cursor(i, j, aoe_hint, validator, range_checker)
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

  if     dir == "UP" then   --UP
    return j >= i and j <= -i
  elseif dir == "RIGHT" then   --RIGHT
    return i >= -j and i <= j
  elseif dir == "DOWN" then   --DOWN
    return j <= i and j >= -i
  elseif dir == "LEFT" then     --LEFT
    return i <= -j and i >= j
  elseif dir == "UPRIGHT" then   --UPRIGHT
    return i <= 0 and j >= 0
  elseif dir == "DOWNRIGHT" then   --DOWNRIGHT
    return i >= 0 and j >= 0
  elseif dir == "DOWNLEFT" then   --DOWNLEFT
    return i >= 0 and j <= 0
  elseif dir == "UPLEFT" then   --UPLEFT
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
  queue.push({self.cursor.i, self.cursor.j})

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

function Cursor:init(i, j, aoe_hint, validator, range_checker)
  self.i = i
  self.j = j
  self.aoe_hint = aoe_hint

  self.validator = validator
  self.range_checker = range_checker
end

function Cursor:getPos()
  return self.i, self.j
end

return SectorView

