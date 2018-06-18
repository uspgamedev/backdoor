
local FX = {}

FX.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'vfx', name = "Visual Effect", type = 'enum',
    options = { 'SLIDE', 'JUMP' } },
  { id = 'vfx-spd', name ="Animation Speed", type = 'float',
    range = {0.1, 10.0}, default = 1.0 },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.preview(_, fieldvalues)
  return "Movement effect"
end

function FX.process (actor, fieldvalues)
  local pos = {actor:getPos()}
  local body = fieldvalues['body']
  local target_pos = fieldvalues['pos']
  local sfx = fieldvalues['sfx']
  if pos[1] == target_pos[1] and pos[2] == target_pos[2] then
    return
  end
  local sector = body:getSector()
  sector:putBody(body, unpack(target_pos))
  if fieldvalues['vfx'] == 'SLIDE' then
    coroutine.yield('report', {
      type = 'body_moved',
      body = body,
      origin = pos,
      sfx = sfx,
      speed_factor = fieldvalues['vfx-spd']
    })
  elseif fieldvalues['vfx'] == 'JUMP' then
    coroutine.yield('report', {
      type = 'body_jumped',
      body = body,
      origin = pos,
      sfx = sfx,
      speed_factor = fieldvalues['vfx-spd']
    })
  else
    coroutine.yield('report', {
      sfx = sfx,
    })
  end
end

return FX

