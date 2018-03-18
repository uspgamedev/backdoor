
local FX = {}

FX.schema = {
  { id = 'text', name = "Text", type = 'value', match = 'integer',
    range = {0} }
}

function FX.process (actor,fieldvalues)
  print(fieldvalues.text)
end

return FX
