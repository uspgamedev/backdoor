
return {
  { id = 'name', name = "Full Name", type = "string" },
  { id = 'image', name = "Icon", type = 'enum', options = 'resources.texture' },
  { id = 'icon_color', name = "Icon Color", type = 'enum', options = {"black", "white"} },
  { id = 'pack_color', name = "Pack Color", type = 'enum', options = {
    "RED", "YELLOW", "ORANGE", "PURPLE", "BLUE", "GREEN", "GREY", "WHITE"} },
  { id = 'description', name = "Description", type = 'text' },
  {
    id = 'cards', name = "Cards", type = 'array',
    schema = {
      { id = 'set', name = "Card Set", type = 'enum',
        options = 'domains.cardset' },
      { id = 'drop', name = "Drop Weight", type = 'integer',
        range = {1, 100} },
    }
  }
}
