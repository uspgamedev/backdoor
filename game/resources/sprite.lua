
local DB = require 'database'

local Sprite = {}
local _animcache = {}

local floor = math.floor
local min = math.min

local function _time()
  return 1000 * love.timer.getDelta()
end

local function _loadAnimation(info, texture)
  local name = info.texture
  local anim = _animcache[name] if not anim then
    local iw, ih = texture:getDimensions()
    local frames = {}
    for i, frame in ipairs(info.animation) do
      local qx, qy, qw, qh = unpack(frame.quad)
      frames[i] = {}
      frames[i].quad = love.graphics.newQuad(qx, qy, qw, qh, iw, ih)
      frames[i].time = frame.time
      frames[i].offset = frame.offset
    end
    anim = {frames = frames, loop = info.loop}
    _animcache[name] = anim
  end
  return anim
end

function Sprite.new(texture, info)
  local idx, start = 1, 0
  local g = love.graphics
  return function(x, y, r, sx, sy)
    local animation = _loadAnimation(info, texture)
    local last_frame = animation.frames[idx]
    start = start + _time()
    if start >= last_frame.time then
      if animation.loop then
        idx = idx % #animation.frames + 1
      else
        idx = min(idx + 1, #animation.frames)
      end
      last_frame = false
      start = 0
    end
    local frame = last_frame or animation.frames[idx]
    g.draw(texture, frame.quad, x, y, r, sx, sy, unpack(frame.offset))
  end
end

return Sprite

