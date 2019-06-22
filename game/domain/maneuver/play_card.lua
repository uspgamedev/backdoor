
local ACTIONDEFS  = require 'domain.definitions.action'
local TRIGGERS    = require 'domain.definitions.triggers'
local ABILITY     = require 'domain.ability'

local PLAYCARD = {}

PLAYCARD.input_specs = {
  { output = 'card_index', name = 'card_index' }
}

local function _card(actor, inputvalues)
  return actor:getHandCard(inputvalues.card_index)
end

function PLAYCARD.card(actor, inputvalues)
  return _card(actor, inputvalues)
end

function PLAYCARD.activatedAbility(actor, inputvalues)
  local card = _card(actor, inputvalues)
  return card:isArt() and card:getArtAbility()
end

function PLAYCARD.exhaustionCost(actor, inputvalues)
  local card = _card(actor, inputvalues)
  if card:isArt() then
    return card:getArtCost()
  elseif card:isWidget() then
    return ACTIONDEFS.PLAY_WIDGET_COST
  end
  return 0
end

function PLAYCARD.validate(actor, inputvalues)
  local card = _card(actor, inputvalues)
  local valid = false
  if card:isArt() then
    valid = actor:getFocus() >= card:getArtCost()
        and ABILITY.checkInputs(card:getArtAbility(), actor, inputvalues)
  elseif card:isWidget() then
    valid = true
  end
  return valid
end

function PLAYCARD.perform(actor, inputvalues)
  local card = _card(actor, inputvalues)
  local body = actor:getBody()
  actor:playCard(inputvalues.card_index)

  if card:isArt() then
    actor:exhaust(card:getArtCost())
    ABILITY.execute(card:getArtAbility(), actor, inputvalues)
    body:triggerWidgets(TRIGGERS.ON_ACT)
  elseif card:isWidget() then
    actor:exhaust(ACTIONDEFS.PLAY_WIDGET_COST)
    body:placeWidget(card)
  end

  coroutine.yield('report', {
    type = 'body_acted',
    body = body,
  })

  body:triggerWidgets(TRIGGERS.ON_PLAY, { card = card })
end

return PLAYCARD

