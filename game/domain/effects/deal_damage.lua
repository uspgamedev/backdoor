
local FX = {}

FX.schema = {
}

function FX.process (actor, sector, target, amount)
  target:takeDamage(amount or 2)
end

return FX

