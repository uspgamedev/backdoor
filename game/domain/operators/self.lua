
--- Get controlled actor

local OP = {}

OP.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'actor'

function OP.process(actor, _)
  return actor
end

function OP.preview(_, _)
  return "self"
end

return OP

