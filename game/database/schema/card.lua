
local DEFS = require 'lux.pack' 'domain.definitions'

return {
  { id = 'name', name = "Name", type = 'string' },
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
          { id = 'attr', name = "Attribute", type = 'enum', options = {"ATH", "ARC", "MEC", "SPD"} },
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
        options = DEFS.widgets, optional = true
      },
      {
        id = 'expend_trigger', name = "Expend Trigger", type = 'enum',
        options = DEFS.triggers
      },
      {
        id = 'widget_action', name = "Action", type = 'enum',
        options = "domains.action"
      }
    },
  }
}
