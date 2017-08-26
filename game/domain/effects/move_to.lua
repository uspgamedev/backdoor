
local FX = {}

FX.schema = {
  { id = 'pos', name = "Position", type = 'value', match = 'pos' }
}

function FX.process (actor, sector,params)
  sector:putBody(actor:getBody(), unpack(params.pos))
end

return FX

