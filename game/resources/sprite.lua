
local DB = require 'database'

local Sprite = {}
local _animcache = {}

local floor = math.floor
local min = math.min
local delta = love.timer.getDelta

local function _time()
  return 1000 * delta()
end

local function _newAnimationQuads(cols, rows, iw, ih)
  local g = love.graphics
  local qw, qh = floor(iw/cols), floor(ih/rows)
  local quads = {}
  for i = 0, rows-1 do
    for j = 0, cols-1 do
      table.insert(quads, g.newQuad(j*qw, i*qh, qw, qh, iw, ih))
    end
  end
  return quads
end

local function _loadAnimation(info, texture)
  local name = info.texture
  local anim = _animcache[name] if not anim then
    local iw, ih = texture:getDimensions()
    local cols, rows = unpack(info.quad_division)
    local ox, oy = unpack(info.offset)
    local quads = _newAnimationQuads(cols, rows, iw, ih)
    local frames = {}
    for i, frame in ipairs(info.animation) do
      frames[i] = {
        quad = quads[frame.quad_idx],
        time = frame.time,
      }
    end
    anim = {
      frames = frames,
      loop = info.loop,
      offset = {ox, oy},
    }
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
    g.draw(texture, frame.quad, x, y, r, sx, sy, unpack(animation.offset))
  end
end

return Sprite

