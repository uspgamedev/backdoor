
local FX = {}

FX.schema = {
  { id = 'pos', name = "Position", type = 'value/pos' }
}

function FX.process (actor, sector, pos)
  sector:putBody(actor:getBody(), unpack(pos))
end

return FX

