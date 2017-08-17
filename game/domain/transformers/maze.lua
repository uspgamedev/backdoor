
local Queue = require 'lux.common.Queue'
local Rand = require 'domain.generators.helpers.random'
local Vector2 = require 'cpml.modules.vec2'

function create(map, margin)
  local progress = Queue(64)
  local start = Vector2(
    Rand.odd(margin + 1, map.getWidth() - margin),
    Rand.odd(margin + 1, map.getHeight() - margin),
  )
  local mazeable = true
  while mazeable do
    --
  end
end


