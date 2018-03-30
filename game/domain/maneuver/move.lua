
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local DB          = require 'database'
local MOVE = {}

MOVE.input_specs = {
  { output = 'pos', name = 'direction' },
}

function MOVE.activatedAbility(actor, inputvalues)
  return nil
end

function MOVE.validate(actor, inputvalues)
  local sector = actor:getBody():getSector()
  return sector:isValid(unpack(inputvalues.pos))
end

function MOVE.perform(actor, inputvalues)
  local sector = actor:getBody():getSector()
  actor:exhaust(ACTIONDEFS.MOVE_COST)
  local pos = {actor:getPos()}
  sector:putBody(actor:getBody(), unpack(inputvalues.pos))
  coroutine.yield('report', {
    type = 'body_moved',
    body = actor:getBody(),
    origin = pos,
    speed_factor = 1.0
  })
  local tile = sector:getTile(unpack(inputvalues.pos))
  local drops = tile.drops
  local inputvalues = {}
  local n = #drops
  local i = 1
  while i <= n do
    local dropname = drops[i]
    local dropspec = DB.loadSpec('drop', dropname)
    if ABILITY.checkInputs(dropspec.ability, actor, inputvalues) then
      table.remove(drops, i)
      n = n-1
      ABILITY.execute(dropspec.ability, actor, inputvalues)
    else
      i = i+1
    end
  end
end

return MOVE

