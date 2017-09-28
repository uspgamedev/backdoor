local DB = require 'database'

local RES = {}

local _rescache = {
  font = {},
  texture = {},
  sfx = {},
  bgm = {},
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
  end
}

function _loadResource(rtype, name, ...)
  local sufix = table.concat({...}, "_")
  local res = _rescache[rtype][name..sufix] if not res then
    local path = DB.loadResourcePath(rtype, name)
    res = _initResource[rtype](path, ...)
    _rescache[rtype][name..sufix] = texture
  end
  return res
end

function RES.loadFont(font_name, size)
  return _loadResource('font', font_name, size)
end

function RES.loadTexture(texture_name)
  return _loadResource('texture', texture_name)
end

function RES.loadSFX(sfx_name)
  return _loadResource('sfx', sfx_name)
end

function RES.loadBGM(bgm_name)
  return _loadResource('bgm', bgm_name)
end

return RES

