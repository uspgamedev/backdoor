
local NEWHAND = {}

function NEWHAND:getRelatedAttr()
  return 'NONE'
end

function NEWHAND:getType()
  return ''
end

function NEWHAND:getName()
  return "New Hand"
end

function NEWHAND:getEffect(player_actor)
  local pp
  if player_actor then
    pp = player_actor:getBody():getConsumption()
  end
  return ("Action [-%s PP]\n\nDiscard your hand, draw five cards."):format(pp)
end

function NEWHAND:getDescription()
  return ""
end

function NEWHAND:getIconTexture()
end

function NEWHAND:isWidget()
end

return NEWHAND

