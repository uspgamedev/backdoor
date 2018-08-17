
return {
  { id = 'extends', name = "Prototype", type = "enum", options = 'domains.body',
    optional = true},
  { id = 'name', name = "Full Name", type = "string" },
  { id = 'appearance', name = "Appearance", type = "enum",
    options = 'domains.appearance' },
  { id = 'faction', name = "Faction", type = "enum",
    options = 'domains.faction'},
  { id = 'res', name = "Resistance", type = "integer", range = {-2,2} },
  { id = 'fin', name = "Finesse", type = "integer", range = {-2,2} },
  { id = 'con', name = "Constitution", type = "integer", range = {-2,2} },
  { id = 'drops', name = 'Drops', type = 'array',
    schema = {
      { id = 'droptype', name = "Drop Type", type = 'enum',
        options = 'domains.drop' },
      { id = 'droprate', name = "Drop Rate", type = 'integer',
        range = {0, 100} },
    },
  },
  { id = 'description', name = "Description", type = 'text' },
}

