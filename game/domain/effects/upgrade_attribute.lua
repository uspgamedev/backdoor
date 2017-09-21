
local FX = {}

FX.schema = {
  { id = 'attribute_name', name = "Attribute", type = 'enum', options = {"ATH", "ARC", "MEC"} },
  { id = 'upgrade_value', name = "Value", type = "integer" }
}

function FX.process(actor, sector, params)
  local attr = params.attribute_name
  local val = params.upgrade_value
  actor["upgrade"..attr](actor, val)
end

return FX

