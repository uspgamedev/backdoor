
local INPUT = {}

INPUT.schema = {}

INPUT.type = 'boolean'

function INPUT.isValid(actor, fieldvalues, value)
  return actor == actor:getSector():getRoute().getControlledActor()
end

return INPUT

