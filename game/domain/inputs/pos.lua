
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'pos'

function INPUT.preview(_, _)
  return "fixed position"
end

function INPUT.isValid(_, _, _)
  return true
end

return INPUT
