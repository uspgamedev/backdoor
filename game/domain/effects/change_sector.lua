
local FX = {}

FX.schema = {
  { id = 'target_sector', name = "Target Sector", type = 'value',
    match = 'sector' },
  { id = 'target_pos', name = "Target Position", type = 'value', match = 'pos' }
}

function FX.process(actor, params)
  local target_sector = Util.findId(params.target_sector)
  target_sector:putActor(actor, unpack(params.target_pos))
end

return FX

