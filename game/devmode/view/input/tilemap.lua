
local IMGUI = require 'imgui'
local class = require 'lux.class'

local setfenv = setfenv
local print = print
local max, min = math.max, math.min

--- Input editor for tilemap fields.
--  Schema:
--  { id = 'internal-identifier', name = "Visible Label",
--    minwidth = 1, maxwidth = <minwidth>,
--    minheight = 1, maxheight = <minheight>,
--    palette = { ' ', '.' } }
--  Spec:
--  { width = <minwidth>, height = <minheight>, data = { '.', ... } }
local TileMapEditor = class:new()

-- luacheck: no self
function TileMapEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  local _minwidth, _minheight = _fieldschema.minwidth or 1,
                                _fieldschema.minheight or 1
  local _maxwidth, _maxheight = _fieldschema.maxwidth or _minwidth,
                                _fieldschema.maxheight or _minheight
  local _palette = _fieldschema.palette

  local _tilemap = _elementspec[_fieldschema.id] or {
    width = _minwidth,
    height = _minheight,
    data = {}
  }

  local function _clampDimensions(width, height)
    return max(min(width, _maxwidth), _minwidth),
           max(min(height, _maxheight), _minheight)
  end

  local function _resize(newwidth, newheight)
    newwidth, newheight = _clampDimensions(newwidth, newheight)
    local newdata = {}
    for i = 1, newheight do
      for j = 1, newwidth do
        local tile = 1
        if i <= _tilemap.height and j <= _tilemap.width then
          local idx = (i-1) * _tilemap.width + j
          tile = _tilemap.data[idx] or tile
        end
        local idx = (i-1) * newwidth + j
        newdata[idx] = tile
      end
    end
    _tilemap.data = newdata
    _tilemap.width = newwidth
    _tilemap.height = newheight
  end

  _resize(_tilemap.width, _tilemap.height)

  _elementspec[_fieldschema.id] = _tilemap

  function input(_)
    IMGUI.PushID(_fieldschema.id)
    IMGUI.Text(_fieldschema.name)
    do -- dimensions editor
      local newwidth, newheight, changed =
        IMGUI.InputInt2('Dimensions', _tilemap.width, _tilemap.height)
      if changed then _resize(newwidth, newheight) end
    end
    do -- tiles editor
      for i = 1, _tilemap.height do
        for j = 1, _tilemap.width do
          local idx = (i-1) * _tilemap.width + j
          local tile = _tilemap.data[idx]
          local glyph = _palette[tile]
          IMGUI.PushID(("-%d:%d"):format(i, j))
          if IMGUI.SmallButton(glyph) then
            tile = (tile % #_palette) + 1
            _tilemap.data[idx] = tile
          end
          IMGUI.PopID()
          if j < _tilemap.width then
            IMGUI.SameLine()
          end
        end
      end
    end
    IMGUI.PopID()
  end

  function __operator:call(gui)
    return obj.input(gui)
  end
end

return { tilemap = TileMapEditor }

