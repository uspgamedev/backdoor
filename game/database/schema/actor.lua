
return {
  { id = 'extends', name = "Prototype", type = "enum", options = 'actor',
    optional = true },
  { id = 'name', name = "Full Name", type = "string" },
  { id = 'behavior', name = "Behavior", type = "enum",
    options = {'player','random_walk'} },
  { id = 'ath', name = "ATH", type = "integer", range={0} },
  { id = 'arc', name = "ARC", type = "integer", range={0} },
  { id = 'mec', name = "MEC", type = "integer", range={0} },
  { id = 'description', name = "Description", type = 'string' },
}

