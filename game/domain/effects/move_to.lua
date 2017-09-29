
local FX = {}

FX.schema = {
  { id = 'pos', name = "Position", type = 'value', match = 'pos' }
}

function FX.process (actor, sector, params)
  local pos = {actor:getPos()}
  sector:putBody(actor:getBody(), unpack(params.pos))
  coroutine.yield('animation', {
    body = actor:getBody(),
    origin = pos
  })
end

return FX

