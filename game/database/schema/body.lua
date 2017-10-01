
return {
  { id = 'extends', name = "Prototype", type = "enum", options = 'domains.body',
    optional = true},
  { id = 'name', name = "Full Name", type = "string" },
  { id = 'appearance', name = "Appearance", type = "string" },
  { id = 'hp', name = "Hit Points", type = "integer", range = {1,999} },
  { id = 'description', name = "Description", type = 'text' },
}

