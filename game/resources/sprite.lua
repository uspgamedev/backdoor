
--DEPENDENCIES--
local DB = require 'database'


--?????--
local floor = math.floor
local min = math.min
local delta = love.timer.getDelta
local g = love.graphics


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
    frames = frames,
    framecount = #frames,
    loop = info.loop,
    offset = {ox, oy},
  }

  _animcache[name] = anim

  return anim
end


--SPRITE MODULE--
local Sprite = CLASS({
  __includes = ELEMENT
})

function Sprite:init(texture, animation)
  ELEMENT.init(self)
  self.animation = animation
  self.texture = texture
  self.frame = 1
  self.decor = false
  self.timecount = 0
end

function Sprite:getCurrentQuad()
  local animation = self.animation
  local dt = floor(delta()*1000)
  self.timecount = self.timecount + dt
  while self.timecount >= animation.frames[self.frame].time do
    self.timecount = self.timecount - dt
    self.frame = self.frame % animation.framecount + 1
  end
  return animation.frames[self.frame].quad
end

function Sprite:setDecorator(f)
  self.decor = f
end

function Sprite:clearDecorator()
  self.decor = false
end

function Sprite:draw(...)
  if self.decor then
    self:decor(self.render, ...)
  else
    self:render(...)
  end
end

function Sprite:render(x, y)
  local quad = self:getCurrentQuad()
  local tex = self.texture
  local ox, oy = unpack(self.animation.offset)
  g.draw(tex, quad, x, y, 0, 1, 1, ox, oy)
end


--SPRITE LOADER MODULE--
local SpriteLoader = {}

function SpriteLoader.load(name, info, texture)
  local anim = _animcache[name] or _newAnimationMeta(name, info, texture)
  return Sprite(texture, anim)
end

return SpriteLoader

