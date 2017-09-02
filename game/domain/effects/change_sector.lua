
local FX = {}

FX.schema = {
  { id = 'target_sector', name = "Target Sector", type = 'value', match = 'string' },
  { id = 'target_pos', name = "Target Position", type = 'value', match = 'pos' }
}

function FX.process(actor, sector, params)
  local target_sector = Util.findId(params.target_sector)
  target_sector:putActor(actor, unpack(params.target_pos))
end

return FX

