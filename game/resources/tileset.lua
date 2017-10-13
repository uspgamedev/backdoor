
local SCHEMATICS = require 'domain.definitions.schematics'
local TileSet = {}
local _cache = {}

local function _initTileset(info, texture)
  local g = love.graphics
  local w, h = texture:getDimensions()
  local mapping = info.mapping
  local quads = {}
  local offsets = {}
  if mapping then
    for name, dim in pairs(mapping) do
      local tile = SCHEMATICS[name]
      quads[tile] = g.newQuad(dim[1], dim[2], dim[3], dim[4], w, h)
      offsets[tile] = { dim[5], dim[6] }
    end
  end
  return {
    texture = texture,
    quads = quads,
    offsets = offsets,
  }
end

function TileSet.new(name, info, texture)
  local tileset = _cache[name] if not tileset then
    tileset = _initTileset(info, texture)
  end
  return tileset
end

return TileSet

