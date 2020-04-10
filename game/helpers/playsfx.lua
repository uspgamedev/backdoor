
local PROFILE = require 'infra.profile'
local RES = require 'resources'

return function (sfxname)
  local sfx = RES.loadSFX(sfxname)
  local source = sfx:play()
  source:setVolume(PROFILE.getPreference("sfx-volume") / 100)
  return source
end
