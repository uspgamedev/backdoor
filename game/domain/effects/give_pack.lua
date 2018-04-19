
local FX = {}

FX.schema = {
  { id = 'collection', name = "Pack's Collection",
    type = 'enum', options = 'domains.collection' }, 
}

function FX.process (actor, fieldvalues)
  actor:addPrizePack(fieldvalues['collection'])
end

return FX

