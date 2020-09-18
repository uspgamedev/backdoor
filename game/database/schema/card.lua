
local ABILITY = require 'domain.ability'
local DEFS = require 'domain.definitions'
local ATTR = require 'domain.definitions.attribute'

local _CARDS = 'domains.card'

return {
  { id = 'one_time', name = "Is One Time Usage", type = 'boolean' },
  { id = 'temporary', name = "Is Temporary", type = 'boolean' },
  { id = 'name', name = "Name", type = 'string' },
  { id = 'icon', name = "Icon", type = 'enum',
    options = 'resources.texture',
    optional = true },
  { id = 'set', name = "Card Set", type = 'enum', options = 'domains.cardset' },
  { id = 'desc', name = "Description", type = 'text' },
  { id = 'attr', name = "Type (attr)", type = 'enum',
    options = DEFS.CARD_ATTRIBUTES },
  { id = 'mod', name = "Modifier", type = 'enum',
    options = ATTR.MOD },
  { id = 'level', name = "Level", type = 'range', min = 1,
      max = 10, default = 1 },
  { id = 'cost', name = "Cost", type = 'range', min = 0,
      max = DEFS.ACTION.MAX_FOCUS },
  { id = 'half-exhaustion', name = "Half exhaustion", type = 'boolean' },
  { id = 'type-description', type = 'description',
    info = "Cards can be either Arts or Widgets" },
  {
    id = 'art', name = "Art",
    type = 'section',
    schema = {
      { id = 'art_ability', name = "Art Ability", type = 'ability',
        hint = "Happens when card is played from hand" },
    }
  },
  {
    id = 'widget', name = "Widget",
    type = 'section',
    schema = {
      { id = 'tactical-hint', name = "Tactical importance", type = 'enum',
        options = { 'harmful', 'helpful', 'movement', 'healing' } },
      { id = 'charges', name = "Charges", type = 'integer', range = {0}, },
      { id = 'trigger', name = "Spend Trigger", type = 'enum',
        options = DEFS.TRIGGERS },
      { id = 'trigger-condition', name = "Spend Trigger Condition",
        type = 'ability', optional = true },
      {
        id = 'static', name = "Static Abilities",
        type = 'array', schema = {
          { id = 'op', name = "Operation or Effect", type = 'enum',
            options = ABILITY.allOperationsAndEffects() },
          { id = 'replacement-ability', name = "Condition and Replacement",
            type = 'ability', disable_effects = true,
            hint = "When the inputs are met, the operation\n" ..
                   "or effect are replaced by the effects here" },
          { id = 'descr', name = "Rules Text", type = 'text' },
        }
      },
      {
        id = 'operators', name = "Static Attribute Operator",
        type = 'array', schema = {
          { id = 'attr', name = "Attribute", type = 'enum',
            options = DEFS.ALL_ATTRIBUTES },
          { id = 'op', name = "Operator", type = 'enum',
            options = { '+', '-', '*', '/' } },
          { id = 'val', name = "Value", type = 'integer' },
        }
      },
      {
        id = 'status-tags', name = "Status Tag", type = 'array',
        schema = {
          { id = 'tag', name = "Tag", type = 'enum',
            options = DEFS.STATUS_TAGS }
        }
      },
      {
        id = 'auto_activation', name = "Triggered Ability", type = 'section',
        schema = {
          { id = 'trigger', name = "Trigger", type = 'enum',
            options = DEFS.TRIGGERS },
          { id = 'ability', name = "Ability", type = 'ability',
            hint = "Happens when trigger is detected" }
        }
      },
      {
        id = 'equipment', name = "Equipment", type = 'section',
        schema = {
             { id = 'active', name = "Active", type = 'section',
                       schema = { { id = 'cards', name = "Action Card",
                                    type = 'array',
                                    schema = { { id = 'card', name = 'Card',
                                                 type = 'enum',
                                                 options = _CARDS } } } } },
             { id = 'defensive', name = "Defensive", type = 'section',
               schema = { { id = 'block_val', name = "Block Value",
                            type = 'integer', range = {0} } } }
        }
      }
    }
  }
}
