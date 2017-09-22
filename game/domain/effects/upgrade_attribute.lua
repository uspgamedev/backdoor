
local FX = {}

FX.schema = {
  { id = 'upgrade_list', name = "Upgrades", type = 'value', match = "upgrade-list" },
}

function FX.process(actor, sector, params)
  for _,upgrade in ipairs(params.upgrade_list) do
    local attr = upgrade.attr
    local val = upgrade.val
    actor["upgrade"..attr](actor, val)
  end
end

return FX

