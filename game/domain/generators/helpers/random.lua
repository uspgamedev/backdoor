
-- dependencies
local rand = love and love.math.random or math.random
local floor = math.floor
local test = ...

local function odd(e, d)
  local e = d and e or 1
  local d = d or e
  if e % 2 == 0 then e = e + 1 end
  if d % 2 == 0 and (d - e) % 2 == 0 then d = d - 1 end
  return e + rand(0, floor((d - e) / 2)) * 2
end

return {
  odd = odd,
  interval = rand,
}

