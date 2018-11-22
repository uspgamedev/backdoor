
local PROFILE = require 'infra.profile'
local RES = require 'resources'

return function (sfxname)
  local sfx = RES.loadSFX(sfxname)
  sfx:setVolume(PROFILE.getPreference("sfx-volume") / 100)
  sfx:play()
  return sfx
end
