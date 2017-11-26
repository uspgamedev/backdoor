
local FX = {}

FX.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' }
}

function FX.process (actor, params)
  local pos = {actor:getPos()}
  local sector = actor:getBody():getSector()
  sector:putBody(actor:getBody(), unpack(params.pos))
  coroutine.yield('report', {
    type = 'body_moved',
    body = actor:getBody(),
    origin = pos
  })
end

return FX

