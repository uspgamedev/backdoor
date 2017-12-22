
local DB = require 'database'
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
    return love.graphics.newFont(path, size)
  end,
  texture = function(path)
    return love.graphics.newImage(path)
  end,
  sfx = function(path)
    return love.audio.newSource(path, "static")
  end,
  bgm = function(path)
    return love.audio.newSource(path, "stream")
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
    _rescache[rtype][name..sufix] = res
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
  return _loadResource('sfx', name)
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

