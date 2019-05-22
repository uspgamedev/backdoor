
return {
  {
    id = 'singletrack', name = "SingleTrack",
    type = 'section',
    schema = {
      { id = "bgm", name = "BGM", type = 'enum', options = 'resources.bgm' },
    }
  },
  {
    id = 'multitrack', name = "MultiTrack",
    type = 'section',
    schema = {
      { id = "default", name = "Default BGM", type = 'enum', options = 'resources.bgm' },
      { id = "danger", name = "Danger BGM", type = 'enum', options = 'resources.bgm' },
      { id = "focused", name = "Focused BGM", type = 'enum', options = 'resources.bgm' },
    }
  },
  { id = "tileset", name = "TileSet", type = 'enum', options = 'resources.tileset' },
}
