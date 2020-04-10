
local DB           = require 'database'
local SFX          = require 'resources.sfx'
local COMPOUND_RES = require 'lux.pack' 'resources'

local RES = {}

local _rescache = {
  font = {},
  texture = {},
  sfx = {},
  bgm = {},
  frames = {},
  tileset = {},
}

local _initResource = {
  font = function(path, size)
    local font = love.graphics.newFont(path, size)
    font:setFilter('linear', 'linear', 1)
    return font
  end,
  texture = function(path)
    return love.graphics.newImage(path)
  end,
  sfx = function(path, polyphony)
    return SFX.new(path, polyphony)
  end,
  bgm = function(path)
    local src = love.audio.newSource(path, "stream")
    src:setLooping(true)
    return src
  end,
}

function _updateResource(rtype, name, data)
  _rescache[rtype][name] = data
end

function _loadResource(rtype, name, ...)
  local sufix = table.concat({...}, "_")
  local res = _rescache[rtype][name..sufix] if not res then
    local path = DB.loadResourcePath(rtype, name)
    res = _initResource[rtype](path, ...)
    _updateResource(rtype, name..sufix, res)
  end
  return res
end

function RES.loadFont(name, size)
  return _loadResource('font', name, size)
end

function RES.loadTexture(name)
  return _loadResource('texture', name)
end

function RES.loadSFX(name)
  local polyphony = DB.loadResource('sfx', name).polyphony
  return _loadResource('sfx', name, polyphony)
end

function RES.loadBGM(name)
  return _loadResource('bgm', name)
end

function RES.loadSprite(name)
  local info = DB.loadResource('sprite', name)
  local texture = RES.loadTexture(info.texture)
  return COMPOUND_RES.sprite.load(name, info, texture)
end

function RES.loadTileSet(name)
  local info = DB.loadResource('tileset', name)
  local texture = RES.loadTexture(info.texture)
  return COMPOUND_RES.tileset.new(name, info, texture)
end

return RES
