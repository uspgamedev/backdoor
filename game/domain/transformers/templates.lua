
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local PALETTE = { SCHEMATICS.NAUGHT, SCHEMATICS.FLOOR, SCHEMATICS.WALL,
                  SCHEMATICS.ALTAR }

local TRANSFORMER = {}

TRANSFORMER.schema = {
  { id = 'min-amount', name = 'Min. Amount', type = 'integer', range = {1} },
  { id = 'max-amount', name = 'Max. Amount', type = 'integer', range = {1} },
  {
    id = 'template-list', name = "Template", type = 'array',
    schema = {
      { id = 'template-map', name = 'Map', type = 'tilemap',
        minwidth = 5, minheight = 5, maxwidth = 15, maxheight = 15,
        palette = PALETTE },
      {
        id = 'encounters', name = "Encounters", type = 'array',
        schema = {
          { id = 'pos', name = "Position", type = 'vector', size = 2,
          range = { 1, 15, } },
          { id = 'body-specname', name = "Body Specification", type = 'enum',
          options = 'domains.body' },
          { id = 'actor-specname', name = "Actor Specification", type = 'enum',
          options = 'domains.actor', optional = true },
        }
      },
      {
        id = 'drops', name = "Drops", type = 'array',
        schema = {
          { id = 'pos', name = "Position", type = 'vector', size = 2,
          range = { 1, 15, } },
          { id = 'drop-specname', name = "Drop Specification", type = 'enum',
          options = 'domains.drop' },
        }
      },
    }
  }
}

function TRANSFORMER.process(sectorinfo, params)
  local amount = RANDOM.generate(params['min-amount'], params['max-amount'])
  local templates = {}
  for i, v in ipairs(params['template-list']) do
    templates[i] = v
  end

  local count = 0
  for _ = 1, amount do
    if #templates == 0 then break end
    local found_spot = false
    repeat
      local template_idx = RANDOM.generate(#templates)
      local template = table.remove(templates, template_idx)
      local map = template['template-map']
      local w, h = map['width'], map['height']
      for x, y, _ in sectorinfo.grid.iterate() do
        if TRANSFORMER.isEmptySpot(sectorinfo.grid, x, y, w, h) then
          found_spot = { x = x, y = y }
          break
        end
      end
      if found_spot then
        count = count + 1
        TRANSFORMER.fillTiles(sectorinfo.grid, found_spot, map)
        TRANSFORMER.placeDrops(sectorinfo, found_spot, template['drops'])
        TRANSFORMER.placeEncounters(sectorinfo, found_spot,
                                    template['encounters'])
      end
    until found_spot or #templates == 0
  end

  print(("Placed %d templates"):format(count))

  return sectorinfo
end

function TRANSFORMER.isEmptySpot(grid, x, y, w, h)
  for dy = 0, h - 1 do
    for dx = 0, w - 1 do
      if grid.get(x + dx, y + dy) ~= SCHEMATICS.FLOOR then
        return false
      end
    end
  end
  return true
end

function TRANSFORMER.fillTiles(grid, offset, map)
  local mw, mh = grid.getMargins()
  for y = 0, map.height - 1 do
    for x = 0, map.width - 1 do
      local real_x, real_y = mw + offset.x + x, mh + offset.y + y
      local raw = map.data[1 + y * map.width + x]
      local fill = PALETTE[raw]
      grid.set(real_x, real_y, fill)
    end
  end
end

function TRANSFORMER.placeDrops(info, offset, drop_specs)
  local mw, mh = info.grid.getMargins()
  local drops = info.drops or {}
  for j, i, _ in info.grid.iterate() do
      drops[i] = drops[i] or {}
      drops[i][j] = {}
  end
  for _, drop_spec in ipairs(drop_specs) do
    local pos = drop_spec['pos']
    local x, y = mw + offset.x + pos[1] - 1, mh + offset.y + pos[2] - 1
    table.insert(drops[y][x], drop_spec['drop-specname'])
  end
  info.drops = drops
end

function TRANSFORMER.placeEncounters(info, offset, encounter_specs)
  local mw, mh = info.grid.getMargins()
  local encounters = info.encounters or {}
  for _, encounter_spec in ipairs(encounter_specs) do
    local pos = encounter_spec['pos']
    local x, y = mw + offset.x + pos[1] - 1, mh + offset.y + pos[2] - 1
    local encounter = {
      creature = { encounter_spec['actor-specname'],
                   encounter_spec['body-specname'] },
      pos = { y, x } -- EXPECTS [i,j], see sector builder
    }
    table.insert(encounters, encounter)
  end
  info.encounters = encounters
end


return TRANSFORMER

