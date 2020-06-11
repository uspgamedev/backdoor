
local INPUT = {}

INPUT.schema = {
  { id = 'description', name = "Description", type = 'string' },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'pos'

function INPUT.preview(_, fieldvalues)
  return fieldvalues['description'] or "fixed position"
end

function INPUT.isValid(_, _, _)
  return true
end

return INPUT
