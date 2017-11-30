
local RANDOM = require 'common.random'
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
}

function FX.process (actor, params)
  params.target:exterminate()
end

return FX

