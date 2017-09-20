
--- Get body at given position

local OP = {}

OP.schema = {
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'body'

function OP.process(actor, sector, params)
  return sector:getBodyAt(unpack(params.pos))
end

return OP

