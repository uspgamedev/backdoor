
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'widget_slot'

function PARAM.isValid(sector, actor, parameter, value)
  if not actor:getBody():hasWidgetAt(value) then
    return false
  end
  return not not actor:getBody():getWidget(value):getWidgetActivation()
end

return PARAM

