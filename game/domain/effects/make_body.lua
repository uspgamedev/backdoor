
local Card = require 'domain.card'
local DB = require 'database'
local FX = {}

FX.schema = {
  { id = 'bodyspec', name = "Body Type", type = 'enum',
    options = 'domains.body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'vit', name = "VIT upgrades", type = 'value', match = 'integer',
    range = {0} },
  { id = 'def', name = "DEF upgrades", type = 'value', match = 'integer',
    range = {0} },
  {
    id = 'widgets', name = "Starting Widget", type = 'array',
    schema = {
      { id = 'spec', name = "Which", type = 'enum',
        options = 'domains.card' },
    }
  }
}

function FX.preview(_, fieldvalues)
  local name = DB.loadSpec('body', fieldvalues['bodyspec'])['name']
  local str = ("Create %s"):format(name)
  local widgets = fieldvalues['widgets']
  if widgets and #widgets > 0 then
    str = str .. " with "
    local list, n = {}, 0
    for _,widget in ipairs(widgets) do
      n = n + 1
      list[n] = DB.loadSpec('card', widget.spec)['name']
    end
    str = str .. table.concat(list, ', ')
  end
  return str
end

function FX.process (actor, fieldvalues)
  local sector = actor:getBody():getSector()
  local bodyspec = fieldvalues['bodyspec']
  local i,j = unpack(fieldvalues['pos'])
  local body = sector:getRoute().makeBody(sector, bodyspec, i, j)
  local state = body:saveState()
  state.widgets = {}
  for _,widget_fieldvalues in ipairs(fieldvalues['widgets']) do
    local widgetspec = widget_fieldvalues['spec']
    if widgetspec then
      local widget = Card(widgetspec)
      assert(widget:isWidget())
      widget:setOwner(actor)
      table.insert(state.widgets, widget)
    end
  end
  body:loadState(state)
end

return FX

