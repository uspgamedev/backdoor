
return {
  { id = 'extends', name = "Prototype", type = "enum", options = 'domains.body',
    optional = true},
  { id = 'name', name = "Full Name", type = "string" },
  { id = 'appearance', name = "Appearance", type = "enum",
    options = 'domains.appearance' },
  { id = 'faction', name = "Faction", type = "enum", options = 'domains.faction'},
  { id = 'vit', name = "Vitality", type = "integer", range = {-4,4} },
  { id = 'def', name = "Defense", type = "integer", range = {-4,4} },
  { id = 'def_die', name = "Defense Die", type = "integer", range = {1,999} },
  { id = 'description', name = "Description", type = 'text' },
}

