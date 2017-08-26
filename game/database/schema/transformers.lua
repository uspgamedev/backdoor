
local transformers = require 'lux.pack' 'domain.transformers'

return setmetatable(
  {},
  { __index = function(t,k) return transformers[k].schema end }
)

