
return {
  { id = 'name', name = "Full Name", type = "string" },
  { id = 'description', name = "Description", type = 'text' },
  {
    id = 'cards', name = "Cards", type = 'array',
    schema = {
      { id = 'card', name = "Card", type = 'enum', options = 'domains.card' }
    }
  }
}

