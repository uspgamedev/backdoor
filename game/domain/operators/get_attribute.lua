
--- Get an attribute value of user

local OP = {}

OP.schema = {
  { id = 'which', name = "Attribute", type = 'enum',
    options = {'COR', 'ARC', 'ANI' } },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, params)
  return actor["get"..params.which](actor)
end

return OP

