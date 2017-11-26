
local Card = require 'domain.card'
local FX = {}

FX.schema = {
  { id = 'bodyspec', name = "Body Type", type = 'enum',
    options = 'domains.body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'vit', name = "VIT upgrades", type = 'value', match = 'integer',
    range = {0} },
  { id = 'def', name = "DEF upgrades", type = 'value', match = 'integer',
    range = {0} },
  { id = 'widgetspec', name = "Starting Widget", type = 'enum',
    options = 'domains.card' },
}

function FX.process (actor, params)
  local sector = actor:getBody():getSector()
  local bodyspec = params['bodyspec']
  local i,j = unpack(params['pos'])
  local body = sector:getRoute().makeBody(bodyspec, i, j)
  local state = {}
  if type(params['widgetspec']) == 'string' then
    local widget = Card(params['widgetspec'])
    assert(widget:isWidget())
    widget:setOwner(actor)
    state.widgets = { widget }
  end
  state.upgrades = {
    VIT = params['vit'],
    DEF = params['def'],
  }
  body:loadState(setmetatable(state, { __index = body:saveState() }))
end

return FX

