
local OP = {}

OP.schema = {
  { id = 'arg1', name = "Argument 1", type = 'value' },
  { id = 'arg2', name = "Argument 2", type = 'value' },
  { id = 'code', name = "Lua snippet", type = 'text' },
  { id = 'description', name = "Description", type = 'text' },
  { id = 'output', name = "Label", type = 'output' }
}

function OP.process(_, fieldvalues)
  local chunk = assert(loadstring(fieldvalues['code'], "snippet"))
  setfenv(chunk, fieldvalues)
  return chunk()
end

function OP.preview(_, fieldvalues)
  return fieldvalues['description']
end

return OP
