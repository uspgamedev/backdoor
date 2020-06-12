
local PROFILE = require 'infra.profile'
local RES = require 'resources'

return function (sfxname, pitch_var)
  local sfx = RES.loadSFX(sfxname)
  local source = sfx:play()
  source:setVolume(PROFILE.getPreference("sfx-volume") / 100)
  if pitch_var then
    source:setPitch(1 + love.math.random()*2*pitch_var - pitch_var)
  end
  return source
end
