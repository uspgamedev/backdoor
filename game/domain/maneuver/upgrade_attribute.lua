
local maneuver = {}

maneuver.schema = {
  { id = 'upgrades', type = 'upgrade_list' },
  { id = 'cost', type = 'exp_cost' }
}

function maneuver.validate(actor, sector, params)
  return params.upgrades and params.cost and params.cost >= actor:getExp()
end

function maneuver.perform(actor, sector, params)
  actor:modifyExpBy(-params.cost)
  for _,upgrade in ipairs(params.upgrades.actor) do
    local attr = upgrade.attr
    local val = upgrade.val
    actor["upgrade"..attr](actor, val)
  end
  local body = actor:getBody() if body then
    for _,upgrade in ipairs(params.upgrades.body) do
      local attr = upgrade.attr
      local val = upgrade.val
      body["upgrade"..attr](body, val)
    end
  end
end

return maneuver

