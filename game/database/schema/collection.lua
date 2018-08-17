
return {
  { id = 'name', name = "Full Name", type = "string" },
  { id = 'image', name = "Image", type = 'enum', options = 'resources.texture' },
  { id = 'description', name = "Description", type = 'text' },
  {
    id = 'cards', name = "Cards", type = 'array',
    schema = {
      { id = 'set', name = "Card Set", type = 'enum',
        options = 'domains.cardset' },
      { id = 'drop', name = "Drop Rate", type = 'integer',
        range = {1, 100} },
    }
  }
}
