
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local SCHEMATICS = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'w', name = "Width", type = 'integer', range = {1} },
  { id = 'h', name = "Height", type = 'integer', range = {1} },
  { id = 'mw', name = "Horizontal Margin", type = 'integer', range = {0} },
  { id = 'mh', name = "Vertical Margin", type = 'integer', range = {0} },
  { id = 'fill_tile', name = "Fill Tile", type = 'enum', options = SCHEMATICS },
  { id = 'margin_tile', name = "Margin Tile", type = 'enum', options = SCHEMATICS },
}

function transformer.process(sectorinfo, params)
  local w = params.w
  local h = params.h
  local mw = params.mw
  local mh = params.mh

  sectorinfo.grid = SectorGrid(w, h, mw, mh, { fill = params['fill_tile'],
                                               margin = params['margin_tile'] })
  return sectorinfo
end

return transformer

