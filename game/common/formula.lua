
local Class = require "steaming.extra_libs.hump.class"

local Formula = Class{}

function Formula:init(value, base_text, bonus)
  self.value = value
  self.base_text = base_text
  self.bonus = bonus or 0
end

function Formula:__add(rhs)
  return Formula(self.value, self.base_text, self.bonus + rhs)
end

function Formula:__sub(rhs)
  return Formula(self.value, self.base_text, self.bonus - rhs)
end

function Formula:__tostring()
  local bonus = ""
  if self.bonus ~= 0 then
    bonus = (" + %d"):format(self.bonus)
  end
  local amount = ""
  if self.value then
    amount = ("%d "):format(self.value + self.bonus)
  end
  return ("%s(%s%s)"):format(amount, self.base_text, bonus)
end

return Formula

