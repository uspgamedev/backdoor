
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'integer'

function INPUT.isValid(actor, fieldvalues, value)
  return actor:getExp() >= value
end

return INPUT

