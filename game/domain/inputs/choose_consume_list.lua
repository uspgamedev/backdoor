
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "choose_consume_list", type = 'output' },
  { id = 'max', name = "Max consumable cards", type = 'value',
    match = 'integer', range = {1} }
}

INPUT.type = 'consume_list'

function INPUT.preview(actor, fieldvalues)
  return fieldvalues['max']
end

function INPUT.isValid(actor, fieldvalues, value)
  return true
end

return INPUT

