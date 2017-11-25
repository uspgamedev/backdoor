
local FX = {}

FX.schema = {
  { id = 'bodyspec', name = "Body Type", type = 'enum',
    options = 'domains.body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  {
    id = 'state', name = "Body State", type = 'section', required = true,
    schema = {
      { id = 'vit', name = "VIT upgrades", type = 'value', match = 'integer',
        range = {0} },
      { id = 'def', name = "DEF upgrades", type = 'value', match = 'integer',
        range = {0} },
    }
  }
}

function FX.process (actor, sector, params)
  local bodyspec = params['bodyspec']
  local i,j = unpack(params['pos'])
  local body = sector:getRoute().makeBody(bodyspec, i, j)
  local state_data = params['state']
  local state = {}
  state.upgrades = {
    VIT = state_data['vit'],
    DEF = state_data['def'],
  }

end

return FX

