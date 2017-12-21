
local FX = {}

FX.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'vfx', name = "Visual Effect", type = 'enum',
    options = { 'SLIDE', 'JUMP' } },
  { id = 'vfx-spd', name ="Animation Speed", type = 'float',
    range = {0.1, 10.0} }
}

function FX.process (actor, params)
  local pos = {actor:getPos()}
  local body = params['body']
  local target_pos = params['pos']
  if pos[1] == target_pos[1] and pos[2] == target_pos[2] then
    return
  end
  local sector = body:getSector()
  sector:putBody(body, unpack(target_pos))
  if params['vfx'] == 'SLIDE' then
    coroutine.yield('report', {
      type = 'body_moved',
      body = body,
      origin = pos,
      speed_factor = params['vfx-spd']
    })
  end
end

return FX

