
local ABILITY    = require 'domain.ability'
local ACTIONDEFS = require 'domain.definitions.action'
local SCHEMATICS = require 'domain.definitions.schematics'
local INTERACT = {}

local CONSUME_ABILITY = {
  inputs = {
    { type = "input",
      output = "label",
      name = "choose_consume_list",
      max = 2 }
  },
  effects = {
    { type = "effect",
      name = "consume_cards",
      card_list = "=label" }
  }
}

INTERACT.input_specs = {
}

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
      inputvalues.sector = id
      inputvalues.pos = exit.target_pos
    elseif sector:getTile(i, j).type == SCHEMATICS.ALTAR
       and actor:isHandEmpty() then
      inputvalues.interaction = 'CONSUME_CARDS'
    end
  end
  return inputvalues.interaction
end

function INTERACT.activatedAbility(actor, inputvalues)
  _seek(actor, inputvalues)
  if inputvalues.interaction == 'CONSUME_CARDS' then
    return CONSUME_ABILITY
  else
    return nil
  end
end

function INTERACT.exhaustionCost(actor, inputvalues)
  return ACTIONDEFS.MOVE_COST
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
  elseif inputvalues.interaction == 'CONSUME_CARDS' then
    ABILITY.execute(CONSUME_ABILITY, actor, inputvalues)
    actor:getSector():getTile(actor:getPos()).type = SCHEMATICS.FLOOR
  end
end

return INTERACT

