
-- luacheck: globals love
local behaviors = love.filesystem.getDirectoryItems("domain/behaviors/")
do
  for i=1, #behaviors do
    behaviors[i] = behaviors[i]:gsub("[.]lua", "")
  end
end

return {
  { id = 'extends', name = "Prototype", type = 'enum',
    options = 'domains.actor', optional = true },
  { id = 'name', name = "Full Name", type = 'string' },
  { id = 'description', name = "Description", type = 'text' },
  { id = 'behavior', name = "Behavior", type = 'enum',
    options = behaviors },
  { id = 'traits', name = "Traits", type = 'array',
    schema = {
      { id = 'specname', name = "Trait", type = 'enum',
      options = "domains.card" },
    }
  },
  { id = 'cor', name = "COR Aptitude", type = 'range', min = -2, max = 2 },
  { id = 'arc', name = "ARC Aptitude", type = 'range', min = -2, max = 2 },
  { id = 'ani', name = "ANI Aptitude", type = 'range', min = -2, max = 2 },
  { id = 'initial_buffer', name = "Buffer Card", type = 'array',
    schema = {
      { id = 'card', name = "Card", type = 'enum', options = "domains.card" },
      { id = 'amount', name = "Amount", type = 'integer', range = {1,16} },
    }
  },
}
