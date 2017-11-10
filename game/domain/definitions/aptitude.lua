
local APT = {}

function APT.REQUIRED_ATTR_UPGRADE(apt, lv)
  return math.ceil((15 - 1.5*apt) ^ (1 + lv/10))
end

function APT.ATTR_LEVEL(owner, which)
  local lv = 0
  local required = 0
  repeat
    required = required +
               APT.REQUIRED_ATTR_UPGRADE(owner:getSpec(which:lower()), lv)
    lv = lv + 1
  until owner.upgrades[which] < required
  return lv-1
end

return APT

