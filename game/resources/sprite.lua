--DEPENDENCIES--
local Class = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

--?????--
local floor = math.floor
local min = math.min
local delta = love.timer.getDelta -- luacheck: globals love
local g = love.graphics           -- luacheck: globals love


--LOCAL VARS--
local _animcache = {}


--LOCAL FUNCTIONS--
local function _newAnimationMeta(name, info, texture)
  local cols, rows = unpack(info.quad_division)
  local ox, oy = unpack(info.offset)
  local iw, ih = texture:getDimensions()
  local qw, qh = floor(iw/cols), floor(ih/rows)
  local quads = {}
  local frames = {}

  for i = 0, rows-1 do
    for j = 0, cols-1 do
      table.insert(quads, g.newQuad(j*qw, i*qh, qw, qh, iw, ih))
    end
  end

  for i, frame in ipairs(info.animation) do
    frames[i] = {
      quad = quads[frame.quad_idx],
      time = frame.time,
    }
  end

  local anim = {
    frame_size = {qw, qh},
    frames = frames,
    framecount = #frames,
    loop = info.loop,
    offset = {ox, oy},
  }

  _animcache[name] = anim

  return anim
end

--SPRITE MODULE--
local Sprite = Class({
  __includes = ELEMENT
})

function Sprite:init(texture, animation)
  ELEMENT.init(self)
  self.animation = animation
  self.texture = texture
  self.frame = 1
  self.decor = false
  self.timecount = 0
  self.sx, self.sy = 1, 1
end

function Sprite:updateAndGetCurrentQuadOfSprite()
  local animation = self.animation
  local dt = floor(delta()*1000)
  self.timecount = self.timecount + dt
  while self.timecount >= animation.frames[self.frame].time do
    self.timecount = self.timecount - animation.frames[self.frame].time
    if animation.loop then
      self.frame = self.frame % animation.framecount + 1
    else
      self.frame = min(self.frame + 1, animation.framecount)
    end
  end
  return animation.frames[self.frame].quad
end

function Sprite:getDimensions()
  local w, h = unpack(self.animation.frame_size)
  return w * self.sx, h * self.sy
end

function Sprite:getWidth()
  local w, _ = self:getDimensions()
  return w
end

function Sprite:getHeight()
  local _, h = self:getDimensions()
  return h
end

function Sprite:setDecorator(f)
  self.decor = f
end

function Sprite:getScale()
  return self.sx, self.sy
end

function Sprite:setScale(sx, sy)
  if sx then self.sx = sx end
  if sy then self.sy = sy end
end

function Sprite:getOffset()
  local ox, oy = unpack(self.animation.offset)
  return ox * self.sx, oy * self.sy
end

function Sprite:clearDecorator()
  self.decor = false
end

function Sprite:isAnimationFinished()
  return not self.animation.loop
     and self.frame == self.animation.framecount
     and self.timecount >= self.animation.frames[self.frame].time
end

function Sprite:draw(...)
  if self.decor then
    self:decor(...)
  else
    self:render(...)
  end
end

function Sprite:render(x, y)
  local quad = self:updateAndGetCurrentQuadOfSprite()
  local tex = self.texture
  local ox, oy = self:getOffset()
  g.draw(tex, quad, x, y, 0, self.sx, self.sy, ox, oy)
end


--SPRITE LOADER MODULE--
local SpriteLoader = {}

function SpriteLoader.load(name, info, texture)
  local anim = _animcache[name] or _newAnimationMeta(name, info, texture)
  return Sprite(texture, anim)
end

return SpriteLoader
