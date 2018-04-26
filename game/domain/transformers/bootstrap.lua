
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local BUFFER_BUILDER = require 'domain.builders.buffers'
local Actor = require 'domain.actor'
local Body = require 'domain.body'

local transformer = {}

transformer.schema = {
  { id= 'tileset', name = "TileSet", type = 'enum',
    options = "resources.tileset" },
  { id = 'w', name = "Width", type = 'integer', range = {1} },
  { id = 'h', name = "Height", type = 'integer', range = {1} },
  { id = 'mw', name = "Horizontal Margin", type = 'integer', range = {1} },
  { id = 'mh', name = "Vertical Margin", type = 'integer', range = {1} },
}

function transformer.process(sectorinfo, params)
  local _w = params.w
  local _h = params.h
  local _mw = params.mw
  local _mh = params.mh


  sectorinfo.grid = SectorGrid(_w, _h, _mw, _mh)
  return sectorinfo
end

return transformer

