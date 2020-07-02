
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

--- Extra HP provided by an actor's power level and vitality.
--  Essentially, every power level increases max hp by 50% of base hp, and
--  every 1 point in vitality further increases that by 10xVIT %.
function APT.EXTRA_HP(power_level, vit)
  return 0.5 * (1 + power_level) * (1 + vit / 10)
end

--- Effective speed provided by an actor's base speed.
--  Every speed point grants +0.05 turns/cycle.
function APT.SPEED(spd)
  return math.floor(8 + spd/2)
end

--- Focus regeneration rate provided by an actor's skill.
--  Every skill point grants +0.2 focus/cycle.
function APT.FOCUS_REGEN(skl)
  return 0.02 * skl
end

return APT
