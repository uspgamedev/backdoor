
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local PALETTE = { SCHEMATICS.NAUGHT, SCHEMATICS.FLOOR, SCHEMATICS.WALL,
                  SCHEMATICS.ALTAR }

local NUM_PALETTE = { ' ', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' }

local TRANSFORMER = {}

TRANSFORMER.schema = {
  { id = 'min-amount', name = 'Min. Amount', type = 'integer', range = {1} },
  { id = 'max-amount', name = 'Max. Amount', type = 'integer', range = {1} },
  {
    id = 'template-list', name = "Template", type = 'array',
    schema = {
      { id = 'tile-map', name = 'Tiles', type = 'tilemap',
        minwidth = 2, minheight = 2, maxwidth = 15, maxheight = 15,
        palette = PALETTE },
      {
        id = 'drops', name = "Drops", type = 'section',
        schema = {
          { id = 'drops-offset', name = "Offset", type = 'vector', size = 2,
            range = { 0, 15, } },
          { id = 'drops-map', name = 'Positions', type = 'tilemap',
            minwidth = 2, minheight = 2, maxwidth = 15, maxheight = 15,
            palette = NUM_PALETTE },
          {
            id = 'drops-specs', name = "Specs", type = 'array',
            schema = {
              { id = 'drop-specname', name = "Drop Specification",
                type = 'enum', options = 'domains.drop' },
              { id = 'drop-amount', name = "Amount",
                type = 'integer', range = {1,6} },
            }
          }
        }
      },
      {
        id = 'encounters', name = "Objects and Creatures", type = 'section',
        schema = {
          { id = 'encounter-offset', name = "Offset", type = 'vector', size = 2,
            range = { 0, 15, } },
          { id = 'encounter-map', name = 'Positions', type = 'tilemap',
            minwidth = 2, minheight = 2, maxwidth = 15, maxheight = 15,
            palette = NUM_PALETTE },
          {
            id = 'encounter-specs', name = "Specs", type = 'array',
            schema = {
              { id = 'body-specname', name = "Body Specification",
                type = 'enum', options = 'domains.body' },
              { id = 'actor-specname', name = "Actor Specification",
                type = 'enum', options = 'domains.actor', optional = true },
            }
          }
        }
      },
    }
  }
}

function TRANSFORMER.process(sectorinfo, params)
  local amount = RANDOM.generate(params['min-amount'], params['max-amount'])
  local templates = {}

  local count = 0
  for _ = 1, amount do
    if #templates == 0 then
      for i, v in ipairs(params['template-list']) do
        templates[i] = v
      end
    end
    local found_spot = false
    repeat
      local template_idx = RANDOM.generate(#templates)
      local template = table.remove(templates, template_idx)
      local map = template['tile-map']
      local w, h = map['width'], map['height']
      for x, y, _ in sectorinfo.grid.iterate() do
        if TRANSFORMER.isEmptySpot(sectorinfo, x, y, w, h) then
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

  return sectorinfo
end

function TRANSFORMER.hasAnyEncountersAt(encounters, x, y)
  if encounters then
    for _, encounter in ipairs(encounters) do
      if encounter.pos[1] == y and encounter.pos[2] == x then
        return true
      end
    end
  end
  return false
end

function TRANSFORMER.isEmptySpot(info, x, y, w, h)
  for dy = 0, h - 1 do
    for dx = 0, w - 1 do
      local sx, sy = x + dx, y + dy
      if not info.grid.isInsideMargins(sx, sy)
          or info.grid.get(sx, sy) ~= SCHEMATICS.FLOOR
          or TRANSFORMER.hasAnyEncountersAt(info.encounters, sx, sy) then
        return false
      end
    end
  end
  return true
end

function TRANSFORMER.fillTiles(grid, offset, map)
  for y = 0, map.height - 1 do
    for x = 0, map.width - 1 do
      local real_x, real_y = offset.x + x, offset.y + y
      local raw = map.data[1 + y * map.width + x]
      local fill = PALETTE[raw]
      grid.set(real_x, real_y, fill)
    end
  end
end

function TRANSFORMER.placeDrops(info, offset, drops_template)
  if not drops_template then return end
  local drops = info.drops or {}
  for j, i, _ in info.grid.iterate() do
      drops[i] = drops[i] or {}
      drops[i][j] = drops[i][j] or {}
  end
  local ox = offset.x + drops_template['drops-offset'][1]
  local oy = offset.y + drops_template['drops-offset'][2]
  local map = drops_template['drops-map']
  local specs = drops_template['drops-specs']
  for dy = 0, map.height - 1 do
    for dx = 0, map.width - 1 do
      local x, y = ox + dx, oy + dy
      local raw = map.data[1 + dy * map.width + dx]
      local spec = specs[tonumber(NUM_PALETTE[raw])]
      if spec then
        for _ = 1, spec['drop-amount'] or 1 do
          table.insert(drops[y][x], spec['drop-specname'])
        end
      end
    end
  end
  info.drops = drops
end

function TRANSFORMER.placeEncounters(info, offset, encounters_template)
  if not encounters_template then return end
  local encounters = info.encounters or {}
  local ox = offset.x + encounters_template['encounter-offset'][1]
  local oy = offset.y + encounters_template['encounter-offset'][2]
  local map = encounters_template['encounter-map']
  local specs = encounters_template['encounter-specs']
  for dy = 0, map.height - 1 do
    for dx = 0, map.width - 1 do
      local x, y = ox + dx, oy + dy
      local raw = map.data[1 + dy * map.width + dx]
      local spec = specs[tonumber(NUM_PALETTE[raw])]
      if spec then
        local encounter = {
          creature = { spec['actor-specname'],
                       spec['body-specname'] },
          pos = { y, x } -- EXPECTS [i,j], see sector builder
        }
        table.insert(encounters, encounter)
      end
    end
  end
  info.encounters = encounters
end


return TRANSFORMER

