
return {
  { id = 'texture', name = "Texture", type = 'enum',
    options = 'resources.texture' },
  { id = 'loop', name = "Loop", type = 'boolean' },
  { id = 'offset', name = "Offset", type = 'vector', size = 2 },
  { id = 'quad_division', name = "Quad Division", type = 'vector', size = 2,
    signature = {'cols', 'rows'} },
  { id = 'animation', name = "Frame", type = 'array',
    schema = {
      { id = 'quad_idx', name = "Quad Index", type = 'integer',
        range = {1, 999} },
      { id = 'time', name = "Miliseconds", type = 'integer',
        range = {1, 999} },
    }
  }
}

