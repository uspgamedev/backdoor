
return {
  { id = 'name', name = "Zone Name", type = 'string' },
  { id = 'tileset', name = "Tile Set", type = 'enum',
    options = "resources.tileset" },
  { id = 'dificulty', name = "Dificulty Level", type = 'integer',
    range = {0,100} },
}

