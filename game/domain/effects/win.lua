
local FX = {}

FX.schema = {}

function FX.preview()
  return "win the game"
end

function FX.process(actor,fieldvalues)
  coroutine.yield('playerWin')
end

return FX
