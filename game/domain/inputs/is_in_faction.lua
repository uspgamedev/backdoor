
local INPUT = {}

INPUT.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'faction', name = "Body Faction", type = 'enum',
    options = 'domains.faction' },
}

INPUT.type = 'boolean'

function INPUT.isValid(_, fieldvalues, _)
  local body = fieldvalues['body']
  local faction = fieldvalues['faction']
  return body:getFaction() == faction
end

return INPUT

