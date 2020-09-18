
local SCHEMATICS = require 'domain.definitions.schematics'
local TileSet = {}
local _cache = {}

local function _initTileset(info, texture)
  local g = love.graphics -- luacheck: globals love
  local w, h = texture:getDimensions()
  local mapping = info.mapping
  local quads = {}
  local offsets = {}
  local weights = {}
  if mapping then
    for name, alternates in pairs(mapping) do
      local tile = SCHEMATICS[name]
      quads[tile] = {}
      offsets[tile] = {}
      local raw_weights = {}
      local total_weight = 0
      weights[tile] = {}
      for i, data in ipairs(alternates) do
        local dim = data.quad
        local weight = data.weight or 1
        quads[tile][i] = g.newQuad(dim[1], dim[2], dim[3], dim[4], w, h)
        offsets[tile][i] = { dim[5], dim[6] }
        raw_weights[i] = weight
        total_weight = total_weight + weight
      end
      local acc = 0
      for i, weight in ipairs(raw_weights) do
        acc = acc + weight / total_weight
        weights[tile][i] = acc
      end
    end
  end
  return {
    texture = info.texture,
    quads = quads,
    offsets = offsets,
    weights = weights
  }
end

function TileSet.new(name, info, texture)
  local tileset = _cache[name] if not tileset then
    tileset = _initTileset(info, texture)
  end
  return tileset
end

return TileSet

