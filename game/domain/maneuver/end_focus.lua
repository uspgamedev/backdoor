
local ENDFOCUS = {}

ENDFOCUS.input_specs = {}

function ENDFOCUS.card(actor, inputvalues) -- luacheck: no unused
  return nil
end

function ENDFOCUS.activatedAbility(actor, inputvalues) -- luacheck: no unused
  return nil
end

function ENDFOCUS.exhaustionCost(actor, inputvalues) -- luacheck: no unused
  return 0
end

function ENDFOCUS.validate(actor, inputvalues) -- luacheck: no unused
  return actor:isFocused()
end

function ENDFOCUS.perform(actor, inputvalues) -- luacheck: no unused
  actor:endFocus()
end

return ENDFOCUS

