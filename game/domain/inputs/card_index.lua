
local INPUT = {}

INPUT.schema = {
  { id = 'source', name = "Card source", type = 'enum',
    options = { 'HAND', 'PACK' } },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'integer'

function INPUT.isValid(actor, fieldvalues, value)
  return true
end

return INPUT

