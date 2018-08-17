
local RANDOM = require 'common.random'
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
}

function FX.preview()
  return "Destroy target body"
end

function FX.process (actor, fieldvalues)
  fieldvalues.target:exterminate()
end

return FX

