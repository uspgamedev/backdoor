
local ACTIONDEFS = require 'domain.definitions.action'
local INTERACT = {}

INTERACT.input_specs = {
}

function INTERACT.activatedAbility(actor, inputvalues)
  return nil
end

-- FIXME: CHANGE_SECTOR should be an activated ability of interaction with
--        stairs, portals, etc.

local function _seek(actor, inputvalues)
  local sector = actor:getBody():getSector()
  if not inputvalues.interaction then
    -- Try to go through exit
    local i, j = actor:getPos()
    local id, exit = sector:findExit(i, j, true)
    if id then
      inputvalues.interaction = 'CHANGE_SECTOR'
      inputvalues.sector = exit.id
      inputvalues.pos = exit.target_pos
    end
  end
  return inputvalues.interaction
end

function INTERACT.validate(actor, inputvalues)
  return not not _seek(actor, inputvalues)
end

function INTERACT.perform(actor, inputvalues)
  _seek(actor, inputvalues)
  if inputvalues.interaction == 'CHANGE_SECTOR' then
    actor:exhaust(ACTIONDEFS.MOVE_COST)
    local target_sector = Util.findId(inputvalues.sector)
    target_sector:putActor(actor, unpack(inputvalues.pos))
  end
end

return INTERACT

