
-- dependencies
local rand = love and love.math.random or math.random
local setSeed = love and love.math.setRandomSeed or math.randomseed
local floor = math.floor

local function generateSeed()
  return tonumber(tostring(os.time()):sub(-7):reverse())
end

local function odd(e, d)
  assert(d > e or not d and e > 0, "Invalid arguments for function `odd`.")
  if not d then
    d = e
    e = 1
  end
  if e % 2 == 0 then e = e + 1 end
  if d % 2 == 0 and (d - e) % 2 == 0 then d = d - 1 end
  return e + rand(0, floor((d - e) / 2)) * 2
end

local function even(e, d)
  assert(d > e or not d and e > 0, "Invalid arguments for function `even`.")
  if not d then
    d = e
    e = 0
  end
  if e % 2 == 1 then e = e + 1 end
  if d % 2 == 1 and (d - e) % 2 == 1 then d = d - 1 end
  return e + rand(0, floor((d - e) / 2)) * 2
end

return {
  generateSeed = generateSeed,
  setSeed = setSeed,
  interval = rand,
  odd = odd,
  even = even,
}
