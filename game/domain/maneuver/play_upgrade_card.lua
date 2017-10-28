
local maneuver = {}

maneuver.schema = {
  { id = 'card_index', type = 'card_index' }
}

function maneuver.validate(actor, sector, params)
  local card = actor:getHandCard(params.card_index)
  return actor:getExp() >= card:getUpgradeCost()
end

function maneuver.perform(actor, sector, params)
  local card = actor:getHandCard(params.card_index)
  actor:playCard(params.card_index)
  actor:modifyExpBy(-card:getUpgradeCost())
  local upgrades = card:getUpgradesList()
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

