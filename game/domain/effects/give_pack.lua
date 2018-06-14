
local FX = {}

FX.schema = {
  { id = 'collection', name = "Pack's Collection",
    type = 'enum', options = 'domains.collection' }, 
}

function FX.process (actor, fieldvalues)
  actor:addPrizePack(fieldvalues['collection'])
  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'status',
    body = actor:getBody(),
    string = "+Pack",
    sfx = fieldvalues.sfx,
  })
end

return FX

