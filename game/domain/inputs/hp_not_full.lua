
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'boolean'

function INPUT.isValid(actor, _, _)
  local body = actor:getBody()
  return body:getHP() < body:getMaxHP()
end

return INPUT

