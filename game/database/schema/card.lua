
return {
  { id = 'name', name = "Name", type = 'string' },
  {
    id = 'art', name = "Art",
    type = 'section',
    schema = {
      { id = 'art_action', name = "Art Action", type = 'enum', options = 'action' },
    }
  },
  {
    id = 'upgrade', name = "Upgrade",
    type = 'section',
    schema = {
      {
        id = 'list', name = "Attribute Change", type = 'array',
        schema = {
          { id = 'attr', name = "Attribute", type = 'enum', options = {"ATH", "ARC", "MEC"} },
          { id = 'val', name = "Value", type = 'integer' },
        }
      },
    }
  },
}
