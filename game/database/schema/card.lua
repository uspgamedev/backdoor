
local DEFS_PACK = require 'lux.pack' 'domain.definitions'
local DEFS = require 'domain.definitions'


return {
  { id = 'name', name = "Name", type = 'string' },
  { id = 'attr', name = "Type (attr)", type = 'enum',
    options = DEFS.ATTRIBUTES},
  {
    id = 'art', name = "Art",
    type = 'section',
    schema = {
      { id = 'art_action', name = "Art Action", type = 'enum', options = 'domains.action' },
    }
  },
  {
    id = 'upgrade', name = "Upgrade",
    type = 'section',
    schema = {
      { id = 'cost', name = "Exp Cost", type = 'integer', range = {1} },
      {
        id = 'list', name = "Attribute Change", type = 'array',
        schema = {
          { id = 'attr', name = "Attribute", type = 'enum',
            options = DEFS.ATTRIBUTES },
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
      {
        id = 'placement', name = "Placement", type = 'enum',
        options = DEFS_PACK.placements, optional = true
      },
      {
        id = 'expend_trigger', name = "Expend Trigger", type = 'enum',
        options = DEFS_PACK.triggers
      },
      {
        id = 'widget_action', name = "Action", type = 'enum',
        options = "domains.action", optional = true
      }
    },
  }
}
