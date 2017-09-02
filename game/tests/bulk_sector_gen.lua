
local RANDOM = require 'common.RANDOM'
local generator = require 'tests.sector01'
local seed = RANDOM.generateSeed()

return function ()
  for i = 1, 10 do
    local s = RANDOM.generate(0, seed * 2)
    seed = s
    generator(s)
  end
end

