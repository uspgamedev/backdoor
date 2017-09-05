
local RANDOM      = require 'common.random'
local SCHEMATICS  = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  {
  },
}

function transformer.process(sectorinfo, params)
  sectorinfo.encounters = {}
  return sectorinfo
end

return transformer

