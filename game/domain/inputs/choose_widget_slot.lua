
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'widget_slot'

function INPUT.isValid(actor, fieldvalues, value)
  if not actor:getBody():hasWidgetAt(value) then
    return false
  end
  return not not actor:getBody():getWidget(value):getWidgetActivation()
end

return INPUT

