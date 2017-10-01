
return {
  { id = 'texture', name = "Texture", type = 'enum',
    options = 'resources.texture' },
  { id = 'loop', name = "Loop", type = 'boolean' },
  { id = 'animation', name = "Frame", type = 'array',
    schema = {
      { id = 'time', name = "Miliseconds", type = 'integer' },
      { id = 'offset', name = "Offset", type = 'vector', size = 2 },
      { id = 'quad', name = "Quad", type = 'vector', size = 4,
        range = {0}, signature = {'x', 'y', 'w', 'h'} },
    }
  }
}

