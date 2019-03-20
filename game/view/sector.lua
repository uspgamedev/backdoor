local DB          = require 'database'
local RES         = require 'resources'
local Color       = require 'common.color'
local math        = require 'common.math'
local CAM         = require 'common.camera'
local TILE        = require 'common.tile'
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'
local DIR         = require 'domain.definitions.dir'
local ACTION      = require 'domain.definitions.action'
local FONT        = require 'view.helpers.font'
local Queue       = require "lux.common.Queue"
local VIEWDEFS    = require 'view.definitions'
local DIALOGUEBOX = require 'view.dialoguebox'
local SPRITEFX    = require 'lux.pack' 'view.spritefx'
local PLAYSFX     = require 'helpers.playsfx'
local vec2        = require 'cpml'.vec2
local Util        = require "steaming.util"
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"

local SECTOR_TILEMAP      = require 'view.sector.tilemap'
local SECTOR_COOLDOWNBAR  = require 'view.sector.cooldownbar'
local SECTOR_LIFEBAR      = require 'view.sector.lifebar'
local SECTOR_WALL         = require 'view.sector.wall'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _HALF_W = VIEWDEFS.HALF_W
local _HALF_H = VIEWDEFS.HALF_H

local _HEALTHBAR_WIDTH = 56
local _HEALTHBAR_HEIGHT = 4

local _texture
local _tile_offset
local _tile_quads
local _tileset
local _cursor_sprite
local _font
local _sparkles

local _isInCone

local Cursor

local SectorView = Class{
  __includes = { ELEMENT }
}

local function _moveCamera(target, force)
  local i, j = target:getPos()
  local tx, ty = (j-0.5)*_TILE_W, (i-0.5)*_TILE_H
  if force then
    CAM:lookAt(tx, ty)
  else
    CAM:lockPosition(tx, ty)
  end
end

local function _dropId(i, j, k)
  return ("%d:%d:%d"):format(i, j, k)
end

function SectorView:init(route)

  ELEMENT.init(self)

  self.target = nil
  self.cursor = nil
  self.ray_dir = nil
  self.ray_body_block = false
  self.vfx = nil

  self.fov = nil --Fov to apply on the sector

  self.route = route
  self.body_sprites = {}
  self.body_dialogues = {}
  self.drop_offsets = {}
  self.sector = false
  self.sector_changed = false

  _font = _font or FONT.get("Text", 16)

end

function SectorView:getTarget()
  return self.target
end

function SectorView:setCooldownPreview(value)
  return SECTOR_COOLDOWNBAR.setCooldownPreview(value)
end

function SectorView:initSector(sector)
  if sector and sector ~= self.sector then
    local g = love.graphics
    self.sector = sector

    _tileset = RES.loadTileSet(sector:getTileSet())
    _texture = RES.loadTexture(_tileset.texture)

    _tile_offset = _tileset.offsets
    _tile_quads = _tileset.quads

    SECTOR_TILEMAP.init(sector, _tileset)
    SECTOR_COOLDOWNBAR.init()
    SECTOR_WALL.load(sector)

    local pixel = RES.loadTexture('pixel')
    _sparkles = g.newParticleSystem(pixel, 256)
    _sparkles:setParticleLifetime(1, 2)
    _sparkles:setEmissionRate(5)
    _sparkles:setSizeVariation(1)
    _sparkles:setLinearAcceleration(0, -40, 0, -5)
    _sparkles:setColors(COLORS.TRANSP,
                        COLORS.NEUTRAL,
                        COLORS.TRANSP)
    _sparkles:setEmissionArea("uniform", 16, 16, 0, false)
    _sparkles:setSizes(2, 4)

    --FIXME: Get tile info from resource cache or something
  end
end

function SectorView:hasPendingVFX()
  return not not self.vfx
end

function SectorView:lookAt(target)
  self.target = target
  if target and target.fov then
    self:updateFov(target)
  end
end

function SectorView:updateVFX(dt)

end

function SectorView:setDropOffset(i, j, k, offset)
  self.drop_offsets[_dropId(i, j, k)] = offset
end

local function _playSFX(target, extra)
  if not target or not target.fov or not extra.body then
    PLAYSFX(extra.sfx)
  else
    if target:canSee(extra.body) then
      PLAYSFX(extra.sfx)
    end
  end
end

function SectorView:startVFX(extra)
  if extra.type then
    local spritefx = SPRITEFX[extra.type]
    self.vfx = spritefx
    MAIN_TIMER:script(function(wait)
      local ann = Util.findId('announcement')
      if ann:isLocked() then
        while ann:isLocked() do wait(1) end
        wait(0.2)
      end
      spritefx.apply(self, extra)
      --Play SFX if any
      if extra.sfx then
        _playSFX(self.target, extra)
      end
    end)
  elseif extra.sfx then
    _playSFX(self.target, extra)
  end
end

function SectorView:finishVFX()
  self.vfx = nil
end

function SectorView:updateFov(actor)
  local sector = self.route.getCurrentSector()
  self.fov = actor:getFov(sector)
end

function SectorView:setRayDir(dir, body_block)
  self.ray_dir = dir
  self.ray_body_block = body_block
end

function SectorView:getBodySprite(body)
  local id = body:getId()
  local body_sprite = self.body_sprites[id]
  if not body_sprite then
    local idle = DB.loadSpec('appearance', body:getAppearance()).idle
    body_sprite = RES.loadSprite(idle)
    self.body_sprites[id] = body_sprite
  end
  return body_sprite
end

function SectorView:setBodySprite(body, draw)
  self.body_sprites[body:getId()] = draw
end

function SectorView:getBodyDialogue(body, i, j, pi, pj)
  local id = body:getId()

  --Get appropriate position for dialogue box
  local side
  if pj <= j then
    side = "right"
  else
    side = "left"
  end

  local dialogue_box = self.body_dialogues[id]
  if not dialogue_box then
    dialogue_box = DIALOGUEBOX(body, i - 1, j - 1, side)
    self.body_dialogues[id] = dialogue_box
  else
    dialogue_box:setSide(side)
  end
  return dialogue_box
end

function SectorView:resetBodyDialogue(body)
  local id = body:getId()
  self.body_dialogues[id] = nil
end

function SectorView:sectorChanged()
  self.sector_changed = true
end

function SectorView:draw()
  local g = love.graphics
  local dt = love.timer.getDelta()
  local sector = self.route.getCurrentSector()
  self:initSector(sector)
  if not self.sector then return end
  if self.target then
    _moveCamera(self.target, self.sector_changed)
    self.sector_changed = false
  end

  -- update particles
  _sparkles:update(dt)


  -- draw background
  g.setBackgroundColor(COLORS.BACKGROUND)
  g.setColor(COLORS.NEUTRAL)

  -- reset color
  g.push()

  local fov = self.fov
  local fovmask = SECTOR_TILEMAP.calculateFOVMask(g, fov)
  SECTOR_TILEMAP.drawAbyss(g)
  SECTOR_TILEMAP.drawFloor(g)

  -- setting up rays
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
  local dialogue_boxes = {}
  local named
  for i = 0, sector.h-1 do
    local draw_bodies = {}
    local draw_drops = {}
    local highlights = {}
    for j = 0, sector.w-1 do
      local tile = sector.tiles[i+1][j+1]
      if CAM:isTileInFrame(i, j) and tile then
        -- Add tiles to spritebatch
        local body = sector.bodies[i+1][j+1]
        local x = j*_TILE_W
        if self.cursor then
          local current_body = self.route.getControlledActor():getBody()
          if not self.fov or (self.fov[i+1][j+1] and
                              self.fov[i+1][j+1] > 0)
                          or body == current_body then
            if self.cursor.range_checker(i+1, j+1) then
              table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                         Color.fromInt {100, 200, 200, 100} })
            end
            if self.cursor.validator(i+1, j+1) then
              table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                         Color.fromInt {100, 200, 100, 100} })
            end
            local ci, cj = self.cursor:getPos()
            local size   = self.cursor.aoe_hint or 1
            local abs    = math.abs
            if size and tile.type == SCHEMATICS.FLOOR
                    and abs(i+1 - ci) < size and abs(j+1 - cj) < size then
              table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                         Color.fromInt {200, 100, 100, 100} })
            end
          end
        elseif self.ray_dir and rays[i+1][j+1] then
          table.insert(highlights, { x, 0, _TILE_W, _TILE_H,
                                     Color.fromInt {200, 100, 100, 100} })
        end
        if body then
          table.insert(draw_bodies, {body, x, 0})
          table.insert(all_bodies, body)
          local player = self.route.getControlledActor():getBody()
          local player_i, player_j = player:getPos()
          local body_i, body_j = body:getPos()
          if body ~= player and TILE.dist(player_i, player_j, body_i, body_j) <= 1 then
            table.insert(dialogue_boxes, self:getBodyDialogue(body, body_i, body_j, player_i, player_j))
          else
            self:resetBodyDialogue(body)
          end
        end

        local dropcount = #tile.drops
        local angle = math.pi*2/dropcount
        local phase = 3*math.pi/4
        for k,drop in ipairs(tile.drops) do
          if not self.fov or (self.fov[i+1][j+1] and
                              self.fov[i+1][j+1] ~= 0) then
            local offset = vec2(0,0)
            local radius = _TILE_W/4
            local t = k-1
            local alpha = t*angle + phase
            local frequency = 3.5
            local amplitude = _TILE_H/8
            local seed = love.timer.getTime() + i*2 + j*3 + k*2
            local oscilation = (math.sin(seed * frequency) - 1) * amplitude
            if dropcount > 1 then
              offset = vec2(math.cos(alpha), -math.sin(alpha)) * radius
            end
            local spread_off = self.drop_offsets[_dropId(i+1, j+1, k)]
            local dx, dy, t = 0, 0, 0
            if spread_off then
              dx = (spread_off.j - (j+1))*_TILE_W
              dy = (spread_off.i - (i+1))*_TILE_H
              t = spread_off.t
            end
            table.insert(draw_drops, {
              drop, x + offset.x + (1-t)*dx, 0 + offset.y + (1-t)*dy,
              2*_TILE_H*(0.25 - (t - 0.5)^2), oscilation
            })
          end
        end
      end
    end

    -- Actually Draw tiles
    g.setColor(COLORS.NEUTRAL)
    SECTOR_WALL.drawRow(i+1, fovmask)

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
          g.setColor(1, 50/255, 50/255)
        end
        _cursor_sprite:draw(0, 0)
        g.pop()
      end
    end

    -- Draw dem bodies
    for _, bodyinfo in ipairs(draw_bodies) do
      local body, x, y = unpack(bodyinfo)
      local i,j = body:getPos()

      --Draw only bodies if player is seeing them
      if not self.fov or (self.fov[i][j] and self.fov[i][j] ~= 0) then

        local body_sprite = self:getBodySprite(body)
        g.setColor(COLORS.NEUTRAL)
        body_sprite:draw(x, y)

      end
    end

    -- Draw drop shadows
    for _,drop in ipairs(draw_drops) do
      local specname, x, y, z, oscilation = unpack(drop)
      local decrease = 1 + math.abs(oscilation)/18
      g.setColor(0, 0, 0, 0.4)
      g.ellipse('fill', x + _TILE_W/2, y + _TILE_H/2, 16/decrease, 6/decrease,
                        16)
    end

    -- Draw drop sprites
    for _,drop in ipairs(draw_drops) do
      local specname, x, y, z, oscilation = unpack(drop)
      local offset = vec2(0,0)
      local sprite = RES.loadTexture(DB.loadSpec('drop', specname).sprite)
      local rx = x + _TILE_W/2 + offset.x
      local ry = y - _TILE_H*.25 + offset.y - z + oscilation
      local iw, ih = sprite:getDimensions()
      g.setColor(COLORS.NEUTRAL)
      g.draw(sprite, rx, ry, 0, 1, 1, 32, 24)
      g.draw(_sparkles, x + _TILE_W/2, y + _TILE_H/2-ih/2, 0, 1, 1, 0, 0)
    end

    g.translate(0, _TILE_H)
  end
  g.pop()

  -- Draw cooldown bars & HP
  for _, body in ipairs(all_bodies) do
    local i,j = body:getPos()
    --Draw only if player is seeing them
    local x, y = (j-0.5)*_TILE_W, (i-0.5)*_TILE_H
    if not self.fov or (self.fov[i][j] and self.fov[i][j] ~= 0) then
      SECTOR_LIFEBAR.draw(body, x, y)
      local actor = body:getActor() if actor then
        local is_controlled = (actor == sector:getRoute().getControlledActor())
        SECTOR_COOLDOWNBAR.draw(actor, x, y, is_controlled)
      end
    end
  end

  --Draw dialogue_boxes
  for _,box in ipairs(dialogue_boxes) do
    box:draw()
  end

  -- name, above everything
  for _,body in ipairs(all_bodies) do
    local i, j = body:getPos()
    if not self.fov or (self.fov[i][j] and self.fov[i][j] ~= 0) then
      local x, y = (j-1)*_TILE_W, (i-1)*_TILE_H
      g.push()
      g.translate(x, y)
      -- NAME
      if named == body then
        local name
        local actor = sector:getActorFromBody(body)
        if actor then
          name = actor:getTitle()
        else
          name = body:getSpec('name')
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
