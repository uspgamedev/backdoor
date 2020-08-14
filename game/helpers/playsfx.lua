
local PROFILE = require 'infra.profile'
local RES = require 'resources'

return function (sfxname)
  local sfx, pitch_var = RES.loadSFX(sfxname)
  local source = sfx:play()
  local random = love.math.random -- luacheck: globals love
  source:setVolume(PROFILE.getPreference("sfx-volume") / 100)
  if pitch_var and pitch_var > 0 then
    source:setPitch(1 + random()*2*pitch_var - pitch_var)
  end
  return source
end
