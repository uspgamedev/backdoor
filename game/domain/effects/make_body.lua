
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
  return ("Create %s"):format(name)
end

function FX.process (actor, fieldvalues)
  local sector = actor:getBody():getSector()
  local bodyspec = fieldvalues['bodyspec']
  local i,j = unpack(fieldvalues['pos'])
  local body = sector:getRoute().makeBody(bodyspec, i, j)
  local state = {}
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
  state.upgrades = {
    VIT = fieldvalues['vit'],
    DEF = fieldvalues['def'],
  }
  body:loadState(setmetatable(state, { __index = body:saveState() }))
end

return FX

