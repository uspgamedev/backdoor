
local IMGUI = require 'imgui'
local class = require 'lux.class'

local setfenv = setfenv
local print = print
local max, min = math.max, math.min

local TileMapEditor = class:new()

function TileMapEditor.instance(_, obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  local _minwidth, _minheight = _fieldschema.minwidth or 1,
                                _fieldschema.minheight or 1
  local _maxwidth, _maxheight = _fieldschema.maxwidth or _minwidth,
                                _fieldschema.maxheight or _minheight

  local _tilemap = _elementspec[_fieldschema.id] or {
    width = _minwidth,
    height = _minheight,
    data = ""
  }

  local function _clampDimensions()
    _tilemap.width = max(min(_tilemap.width, _maxwidth), _minwidth)
    _tilemap.height = max(min(_tilemap.height, _maxheight), _minheight)
  end

  local function _resize(newwidth, newheight)
    _tilemap.width = newwidth
    _tilemap.height = newheight
    _clampDimensions()
    local newdata = ""
    for i = 1, newheight do
      for j = 1, newwidth do
        local tile = ''
        if i <= _tilemap.height or j <= _tilemap.width then
          local idx = (i-1) * _tilemap.width + j
          tile = _tilemap.data:sub(idx, idx)
        end
        if tile == '' then tile = '.' end
        newdata = newdata .. tile
      end
    end
    _tilemap.data = newdata
  end

  local function _toText()
    local text = ""
    for i = 1, _tilemap.height do
      local begin = 1 + (i-1)*_tilemap.width
      text = text .. _tilemap.data:sub(begin, begin + _tilemap.width-1) .. '\n'
    end
    print(text)
    return text
  end

  local function _fromText(text)
    print("apply")
    local newdata = ""
    local scan, last = 1, 1
    print(text)
    while scan <= #text do
      local newchar = text:sub(scan, scan)
      local oldchar = _tilemap.data:sub(last, last)
      if newchar ~= '\n' then
        newdata = newdata .. newchar
        last = last + 1
        if newchar ~= oldchar then
          scan = scan + 1
        end
      end
      scan = scan + 1
    end
    _tilemap.data = newdata
    print(_toText())
  end

  _resize(_tilemap.width, _tilemap.height)

  _elementspec[_fieldschema.id] = _tilemap

  function input(gui)
    IMGUI.PushID(_fieldschema.id)
    IMGUI.Text(_fieldschema.name)
    local newwidth, newheight, changed =
      IMGUI.InputInt2('Dimensions', _tilemap.width, _tilemap.height)
    if changed then _resize(newwidth, newheight) end
    local length = (_tilemap.width+1) * _tilemap.height + 2
    local text, changed = IMGUI.InputTextMultiline("Tilemap", _toText(), length)
    if changed then _fromText(text) end
    IMGUI.PopID()
  end

  function __operator:call(gui)
    return obj.input(gui)
  end
end

return { tilemap = TileMapEditor }

