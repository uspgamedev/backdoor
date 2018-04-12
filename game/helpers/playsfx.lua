
local RES = require 'resources'

return function (sfxname)
  local sfx = RES.loadSFX(sfxname)
  sfx:setVolume(1)
  sfx:stop()
  return sfx:play()
end

