
local FX = {}

FX.schema = {
  { id = 'which', name = "Buffer", type = 'value', match = 'integer',
    range = {1} }
}

function FX.process (actor, sector, params)
  if actor:isHandEmpty() then
    for i = 1,actor:getHandLimit() do
      actor:drawCard(params.which)
    end 
  end
end

return FX

