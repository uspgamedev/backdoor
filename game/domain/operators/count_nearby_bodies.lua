
local OP = {}

OP.schema = {
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'range', name = "Range", type = 'value', match = 'integer',
    range = {0} },
  { id = 'body-type', name = "Body Type", type = 'enum',
    options = 'domains.body' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, params)
  local sector = actor:getBody():getSector()
  local i, j = unpack(params['pos'])
  local range = params['range']
  local specname = params['body-type']
  local count = 0
  for di=i-range,i+range do
    for dj=j-range,j+range do
      if di ~= i or dj ~= j then
        local body = sector:getBodyAt(di, dj)
        if body and body:isSpec(specname) then
          count = count + 1
        end
      end
    end
  end
  return count
end

return OP

