
--- Find last valid position in given direction

local OP = {}

OP.schema = {
  { id = 'pos', name = "Origin", type = 'value', match = 'pos' },
  { id = 'dir', name = "Raycast direction", type = 'value', match = 'dir' },
  { id = 'maxrange', name = "Maximum range", type = 'value', match = 'integer',
    range = {1} },
  { id = 'body-block', name = "Stop on bodies", type = 'boolean',
    default = true },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'pos'

function OP.preview(_, fieldvalues)
  local range = fieldvalues['maxrange']
  local pos = fieldvalues['pos']
  return ("up to %d tiles away from %s"):format(range, pos)
end

local function _positionBlocked(sector, pos, body_block)
  return body_block and not sector:isValid(unpack(pos))
                     or not sector:isWalkable(unpack(pos))
end

function OP.process(actor, fieldvalues)
  local sector = actor:getBody():getSector()
  local pos = {}
  local last_stable_pos = {}
  local next_pos = { unpack(fieldvalues['pos']) } -- Clone it!
  local body_block = fieldvalues['body-block']
  local dir = fieldvalues['dir']
  local maxrange = fieldvalues['maxrange']
  local i = 0
  repeat
    pos[1], pos[2] = unpack(next_pos)
    next_pos[1], next_pos[2] = pos[1]+dir[1], pos[2]+dir[2]
    if sector:isValid(unpack(pos)) then
      last_stable_pos[1], last_stable_pos[2] = unpack(pos)
    end
    i = i + 1
  until i > maxrange or _positionBlocked(sector, next_pos, body_block)
  if body_block then
    return pos
  else
    return last_stable_pos
  end
end

return OP

