
local RANDOM = require 'common.random'
local _seed = RANDOM.generateSeed()
local setSeed = love and love.math.setRandomSeed or math.randomseed
setSeed(seed)

for i = 1, 16 do
  print("odd 0-20", random.odd(0, 20))
end

for i = 1, 16 do
  print("odd 1-20", random.odd(1, 20))
end

for i = 1, 16 do
  print("odd 0-19", random.odd(0, 19))
end

for i = 1, 16 do
  print("odd 1-19", random.odd(1, 19))
end

for i = 1, 16 do
  print("even 0-20", random.even(0, 20))
end

for i = 1, 16 do
  print("even 1-20", random.even(1, 20))
end

for i = 1, 16 do
  print("even 0-19", random.even(0, 19))
end

for i = 1, 16 do
  print("even 1-19", random.even(1, 19))
end
