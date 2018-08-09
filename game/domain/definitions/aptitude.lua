
local APT = {}

--- Calculate required upgrade points for a certain level given an aptitude.
--  For the resulting tables run
--  ```bash
--  $ make FLAGS=--test=aptitude
--  ```
function APT.REQUIRED_ATTR_UPGRADE(apt, lv)
  return math.ceil((15 - 3*apt) ^ (1 + lv/10))
end

function APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(apt, lv)
  local required = 0
  for i = 1, lv do
    required = required + APT.REQUIRED_ATTR_UPGRADE(apt, i)
  end
  return required
end

function APT.ATTR_LEVEL(owner, which)
  local lv = 0
  local required = 0
  repeat
    lv = lv + 1
    required = required +
               APT.REQUIRED_ATTR_UPGRADE(owner:getAptitude(which), lv)
  until owner.upgrades[which] < required
  return lv-1
end

function APT.HP(vit, con)
  return math.floor(20 + (4+con)*vit*vit - (7+con)*vit)
end

function APT.STAMINA(efc, fin)
  local min, max = 7 - 2.5*fin, 25 - fin
  local food = max - (max-min)*efc/12
  return math.floor(food)
end

function APT.ARMORBONUS(def, res)
  return math.floor(0.5 * def * (6 + res) / 4)
end

return APT
