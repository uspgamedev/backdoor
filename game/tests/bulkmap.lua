
local seed = ...
local generator = require 'tests.map1'

if seed then
  print(seed)
  generator.test(seed)
else
  for i = 1, 256 do
    generator.test()
  end
end



