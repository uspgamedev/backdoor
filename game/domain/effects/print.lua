
local FX = {}

FX.schema = {
  { id = 'text', name = "Text", type = 'value', match = 'integer',
    range = {0} }
}

function FX.process (actor, sector,params)
  print(params.text)
end

return FX
