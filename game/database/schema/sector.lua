
return  {
  { id = 'bootstrap', name = "Base Settings", type = 'section',
    schema = 'transformers.bootstrap', required = true },
  { id = 'rooms', name = "Room Settings", type = 'section',
    schema = 'transformers.rooms' },
  { id = 'maze', name = "Maze Settings", type = 'section',
    schema = 'transformers.maze' },
  { id = 'connections', name = "Connection Settings", type = 'section',
    schema = 'transformers.connections' },
  { id = 'deadends', name = "Deadend Settings", type = 'section',
    schema = 'transformers.deadends' },
  { id = 'exits', name = "Exit Settings", type = 'section',
    schema = 'transformers.exits' },
  { id = 'encounters', name = "Encounter Settings", type = 'section',
    schema = 'transformers.encounters' },
}

