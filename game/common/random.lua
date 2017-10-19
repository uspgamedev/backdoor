
--HELPERS--
local floor = math.floor

--LOCALS--
local RANDOM = {}
local _rng = love.math.newRandomGenerator()

--METHODS--
function RANDOM.generate(e, d)
  return _rng:random(e, d)
end

function RANDOM.generateOdd(e, d)
  assert(d > e or not d and e > 0, "Invalid arguments for function `odd`.")
  if not d then
    d = e
    e = 1
  end
  if e % 2 == 0 then e = e + 1 end
  if d % 2 == 0 and (d - e) % 2 == 0 then d = d - 1 end
  return e + _rng:random(0, floor((d - e) / 2)) * 2
end

function RANDOM.generateEven(e, d)
  assert(d > e or not d and e > 0, "Invalid arguments for function `even`.")
  if not d then
    d = e
    e = 0
  end
  if e % 2 == 1 then e = e + 1 end
  if d % 2 == 1 and (d - e) % 2 == 1 then d = d - 1 end
  return e + _rng:random(0, floor((d - e) / 2)) * 2
end

function RANDOM.rollDice(n, d)
  local sum = 0
  for i = 1, n do
    sum = sum + (d == 1 and 1 or RANDOM.generate(1, d))
  end
  return sum
end

function RANDOM.shuffle(t)
  local n = #t
  for i=1,n do
    local j = RANDOM.generate(i,n)
    t[i], t[j] = t[j], t[i]
  end
end

function RANDOM.generateSeed()
  return tonumber(tostring(os.time()):sub(-7):reverse())
end

function RANDOM.setSeed(seed)
  return _rng:setSeed(seed)
end

function RANDOM.getSeed()
  return _rng:getSeed()
end

function RANDOM.getState()
  return _rng:getState()
end

function RANDOM.setState(state)
  return _rng:setState(state)
end

return RANDOM

