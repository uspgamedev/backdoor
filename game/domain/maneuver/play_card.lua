
local TRIGGERS    = require 'domain.definitions.triggers'
local ABILITY     = require 'domain.ability'
local ACTIONDEFS  = require 'domain.definitions.action'

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
  return card:getCost()
end

function PLAYCARD.validate(actor, inputvalues)
  local card = _card(actor, inputvalues)
  return not card:isArt() or
         ABILITY.checkInputs(card:getArtAbility(), actor, inputvalues)
end

function PLAYCARD.perform(actor, inputvalues)
  local card = _card(actor, inputvalues)
  local body = actor:getBody()

  coroutine.yield('report', {
    type = 'body_acted',
    body = body,
  })

  actor:exhaust(ACTIONDEFS.FOCUS_COST)
  body:triggerWidgets(TRIGGERS.ON_PLAY, { card = card })
  if card:isArt() then
    coroutine.yield('report', {
      type = 'play_art_card',
      actor = actor,
      card_index = inputvalues.card_index
    })
    actor:playCard(inputvalues.card_index)
    ABILITY.execute(card:getArtAbility(), actor, inputvalues)
    body:triggerWidgets(TRIGGERS.ON_ACT)
  elseif card:isWidget() then
    body:placeWidget(card)
    coroutine.yield('report', {
      type = 'play_widget_card',
      actor = actor,
      card_index = inputvalues.card_index
    })
    actor:playCard(inputvalues.card_index)
  end
end

return PLAYCARD
