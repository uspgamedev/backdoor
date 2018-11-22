local Util  = require "steaming.util"
local FX = {}

FX.schema = {
  { id = 'target_sector', name = "Target Sector", type = 'value',
    match = 'sector' },
  { id = 'target_pos', name = "Target Position", type = 'value', match = 'pos' }
}

function FX.process(actor, fieldvalues)
  local target_sector = Util.findId(fieldvalues.target_sector)
  target_sector:putActor(actor, unpack(fieldvalues.target_pos))
end

return FX
