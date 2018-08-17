
return {
  { id = 'name', name = "Zone Name", type = 'string' },
  { id = 'theme', name = "Zone Theme", type = 'enum',
    options = "domains.theme"},
  { id = 'difficulty', name = "Difficulty Level", type = 'integer',
    range = {0,100} },
}

