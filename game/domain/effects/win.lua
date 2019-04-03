
local FX = {}

FX.schema = {}

function FX.preview()
  return "win the game"
end

function FX.process(actor,fieldvalues)
  coroutine.yield('playerDead')
end

return FX

