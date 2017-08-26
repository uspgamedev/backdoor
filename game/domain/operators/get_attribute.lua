
local OP = {}

OP.schema = {
  { id = 'which', name = "Attribute", type = 'enum',
    options = {'ATH', 'ARC', 'MEC' } }
}

function OP.process(actor, sector, params)
  return 2
end

return OP

