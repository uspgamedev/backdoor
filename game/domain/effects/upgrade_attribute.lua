
local FX = {}

FX.schema = {
  { id = 'upgrade_list', name = "Upgrades", type = 'value', match = "upgrade-list" },
}

function FX.process(actor, params)
  for _,upgrade in ipairs(params.upgrade_list.actor) do
    local attr = upgrade.attr
    local val = upgrade.val
    actor["upgrade"..attr](actor, val)
  end
  local body = actor:getBody() if body then
    for _,upgrade in ipairs(params.upgrade_list.body) do
      local attr = upgrade.attr
      local val = upgrade.val
      body["upgrade"..attr](body, val)
    end
  end
end

return FX

