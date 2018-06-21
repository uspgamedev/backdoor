
return {
  { id = 'texture', name = "Texture", type = "enum",
    options = 'resources.texture' },
  { id = 'mapping', name = "Mapping", type = 'section',
    required = true,
    schema = {
      { id = 'FLOOR', name = "Floor Quad #", type = 'vector',
        size = 6, range = {0},
        signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} },
      { id = 'WALL', name = "Wall Quad #", type = 'vector',
        size = 6, range = {0},
        signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} },
      { id = 'ALTAR', name = "Altar Quad #", type = 'vector',
        size = 6, range = {0},
        signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} },
      { id = 'EXIT', name = "Exit Quad #", type = 'vector',
        size = 6, range = {0},
        signature = {'ix', 'iy', 'qw', 'qh', 'ox', 'oy'} },
    },
  }
}

