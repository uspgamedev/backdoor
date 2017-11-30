
--- Find last valid position in given direction

local OP = {}

OP.schema = {
  { id = 'pos', name = "Origin", type = 'value', match = 'pos' },
  { id = 'dir', name = "Raycast direction", type = 'value', match = 'dir' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'pos'

function OP.process(actor, params)
  local sector = actor:getBody():getSector()
  local pos = {}
  local next_pos = { unpack(params['pos']) } -- Clone it!
  local dir = params['dir']
  repeat
    pos[1], pos[2] = unpack(next_pos)
    next_pos[1], next_pos[2] = pos[1]+dir[1], pos[2]+dir[2]
  until not sector:isValid(unpack(next_pos))
  return pos
end

return OP

