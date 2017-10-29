
local ACTIONDEFS = require 'domain.definitions.action'
local INTERACT = {}

INTERACT.param_specs = {
}

function INTERACT.activatedAbility(actor, sector, params)
  return nil
end

-- FIXME: CHANGE_SECTOR should be an activated ability of interaction with
--        stairs, portals, etc.

local function _seek(actor, sector, params)
  if not params.interaction then
    -- Try to go through exit
    local i, j = actor:getPos()
    local id, exit = sector:findExit(i, j, true)
    if id then
      params.interaction = 'CHANGE_SECTOR'
      params.sector = exit.id
      params.pos = exit.target_pos
    end
  end
  return params.interaction
end

function INTERACT.validate(actor, sector, params)
  return not not _seek(actor, sector, params)
end

function INTERACT.perform(actor, sector, params)
  _seek(actor, sector, params)
  if params.interaction == 'CHANGE_SECTOR' then
    actor:spendTime(ACTIONDEFS.MOVE_TIME)
    local target_sector = Util.findId(params.sector)
    target_sector:putActor(actor, unpack(params.pos))
  end
end

return INTERACT

