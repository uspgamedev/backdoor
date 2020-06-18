
return {
  { id = 'texture', name = "Texture", type = "enum",
    options = 'resources.texture' },
  { id = 'mapping', name = "Mapping", type = 'section',
    required = true,
    schema = {
      {
        id = 'FLOOR', name = "Floor Tiles", type = 'array',
        schema = {
          { id = 'weight', name = "Weight", type = 'integer', range = {0,10} },
          { id = 'quad', name = "Quad #", type = 'vector',
            size = 6, range = {0},
            signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} }
        }
      },
      {
        id = 'ALTAR', name = "Altar Tiles", type = 'array',
        schema = {
          { id = 'weight', name = "Weight", type = 'integer', range = {0,10} },
          { id = 'quad', name = "Quad #", type = 'vector',
            size = 6, range = {0},
            signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} }
        }
      },
      {
        id = 'EXITDOWN', name = "Exit Down Tiles", type = 'array',
        schema = {
          { id = 'weight', name = "Weight", type = 'integer', range = {0,10} },
          { id = 'quad', name = "Quad #", type = 'vector',
            size = 6, range = {0},
            signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} }
        }
      },
      {
        id = 'EXITUP', name = "Exit Up Tiles", type = 'array',
        schema = {
          { id = 'weight', name = "Weight", type = 'integer', range = {0,10} },
          { id = 'quad', name = "Quad #", type = 'vector',
            size = 6, range = {0},
            signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} }
        }
      }
    }
  }
}

