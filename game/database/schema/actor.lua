
local behaviors = love.filesystem.getDirectoryItems("domain/behaviors/")
do
  for i=1, #behaviors do
    behaviors[i] = behaviors[i]:gsub("[.]lua", "")
  end
end

return {
  { id = 'extends', name = "Prototype", type = 'enum', options = 'domains.actor',
    optional = true },
  { id = 'name', name = "Full Name", type = 'string' },
  { id = 'description', name = "Description", type = 'text' },
  { id = 'behavior', name = "Behavior", type = 'enum',
    options = behaviors },
  { id = 'signature', name = "Signature Ability", type = 'enum',
    options = 'domains.action' },
  { id = 'ath', name = "ATH", type = 'integer', range = {0} },
  { id = 'arc', name = "ARC", type = 'integer', range = {0} },
  { id = 'mec', name = "MEC", type = 'integer', range = {0} },
  { id = 'spd', name = "SPD", type = 'integer', range = {0} },
  { id = 'collection', name = "Drops", type = 'enum',
    options = 'domains.collection' },
  { id = 'initial_buffer', name = "Buffer Card", type = 'array',
    schema = {
      { id = 'card', name = "Card", type = 'enum', options = "domains.card" },
      { id = 'amount', name = "Amount", type = 'integer', range = {1,16} },
    }
  },
}
