
--- Get body at given position

local OP = {}

OP.schema = {
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'range', name = "Range", type = 'value', match = 'integer',
    range = {0} },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'body'

function OP.process(actor, params)
  local sector = actor:getBody():getSector()
  local i, j = unpack(params['pos'])
  local range = params['range']
  local nearest
  local mindist = range+1
  for di=i-range,i+range do
    for dj=j-range,j+range do
      if di ~= i or dj ~= j then
        local body = sector:getBodyAt(di, dj)
        local dist = math.max(math.abs(di-i), math.abs(dj-j))
        if body and dist < mindist then
          nearest = body
          mindist = dist
        end
      end
    end
  end
  return nearest
end

return OP

