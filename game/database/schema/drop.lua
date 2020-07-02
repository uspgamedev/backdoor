
return {
  { id = 'name', name = "Name", type = 'string' },
  { id = "sprite", name = "Sprite", type = 'enum',
    options = 'resources.sprite' },
  { id = 'ability', name = "Triggered Ability", type = 'ability' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

