
local FX = {}

FX.schema = {
}

function FX.process (actor, sector, params)
  if actor:isHandEmpty() then
    for i = 1,actor:getHandLimit() do
      actor:drawCard()
    end 
  end
end

return FX

