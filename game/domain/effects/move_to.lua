
local FX = {}

FX.schema = {
}

function FX.process (actor, sector, pos)
  sector:putBody(actor:getBody(), unpack(pos))
end

return FX

