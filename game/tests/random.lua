
local RANDOM = require 'common.random'
local _seed = RANDOM.generateSeed()
local _setSeed = love and love.math.setRandomSeed or math.randomseed

return function ()
  _setSeed(_seed)

  for i = 1, 16 do
    print("odd 0-20", RANDOM.generateOdd(0, 20))
  end

  for i = 1, 16 do
    print("odd 1-20", RANDOM.generateOdd(1, 20))
  end

  for i = 1, 16 do
    print("odd 0-19", RANDOM.generateOdd(0, 19))
  end

  for i = 1, 16 do
    print("odd 1-19", RANDOM.generateOdd(1, 19))
  end

  for i = 1, 16 do
    print("even 0-20", RANDOM.generateEven(0, 20))
  end

  for i = 1, 16 do
    print("even 1-20", RANDOM.generateEven(1, 20))
  end

  for i = 1, 16 do
    print("even 0-19", RANDOM.generateEven(0, 19))
  end

  for i = 1, 16 do
    print("even 1-19", RANDOM.generateEven(1, 19))
  end
end

