
local FX = {}

FX.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' }
}

function FX.process (actor, params)
  local pos = {actor:getPos()}
  local target_pos = params.pos
  if pos[1] == target_pos[1] and pos[2] == target_pos[2] then
    return
  end
  local sector = actor:getBody():getSector()
  sector:putBody(actor:getBody(), unpack(target_pos))
  coroutine.yield('report', {
    type = 'body_moved',
    body = actor:getBody(),
    origin = pos
  })
end

return FX

