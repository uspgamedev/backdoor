
local DEFS_PACK = require 'lux.pack' 'domain.definitions'
local DEFS = require 'domain.definitions'

return {
  { id = 'one_time', name = "Is One Time Usage", type = 'boolean' },
  { id = 'name', name = "Name", type = 'string' },
  { id = 'set', name = "Card Set", type = 'enum', options = 'domains.cardset' },
  { id = 'desc', name = "Description", type = 'text' },
  { id = 'pp', name = "PlayPoint Reward", type = 'integer' },
  { id = 'attr', name = "Type (attr)", type = 'enum',
    options = DEFS.PRIMARY_ATTRIBUTES },
  {
    id = 'art', name = "Art",
    type = 'section',
    schema = {
      { id = 'cost', name = "Cost", type = 'integer', range = {0} },
      { id = 'art_ability', name = "Art Ability", type = 'ability' },
    }
  },
  {
    id = 'upgrade', name = "Upgrade",
    type = 'section',
    schema = {
      { id = 'cost', name = "Exp Cost", type = 'integer', range = {1} },
      {
        id = 'actor_list', name = "Actor Attribute", type = 'array',
        schema = {
          { id = 'attr', name = "Attribute", type = 'enum',
            options = DEFS.ATTRIBUTES },
          { id = 'val', name = "Value", type = 'integer' },
        }
      },
      {
        id = 'body_list', name = "Body Attribute", type = 'array',
        schema = {
          { id = 'attr', name = "Attribute", type = 'enum',
            options = DEFS.BODY_ATTRIBUTES },
          { id = 'val', name = "Value", type = 'integer' },
        }
      },
    }
  },
  {
    id = 'widget', name = "Widget",
    type = 'section',
    schema = {
      { id = 'charges', name = "Charges", type = 'integer', range = {1} },
      { id = 'trigger', name = "Trigger", type = 'enum',
        options = DEFS.TRIGGERS },
      { id = 'placement', name = "Placement", type = 'enum',
        options = DEFS_PACK.placements, optional = true },
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
        id = 'activation', name = "Activated Ability", type = 'section',
        schema = {
          { id = 'cost', name = "Time Cost", type = 'integer',
            range = {0} },
          { id = 'ability', name = "Ability", type = 'ability',
            optional = true }
        }
      },
      {
        id = 'auto_activation', name = "Triggered Ability", type = 'section',
        schema = {
          { id = 'trigger', name = "Trigger", type = 'enum',
            options = DEFS.TRIGGERS },
          { id = 'ability', name = "Ability", type = 'ability' }
        }
      },
    },
  }
}
