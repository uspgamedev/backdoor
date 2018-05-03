
local RES         = require 'resources'

local SoundTrack  = require 'lux.class' :new{}

local source  = love.source
local setfenv = setfenv

function SoundTrack:instance(obj)

  setfenv(1, obj)

  local bgm = {}

  function playTheme(theme)
    if theme and bgm.id ~= theme.bgm then
      if bgm.stream then bgm.stream:stop() end
      bgm.stream = RES.loadBGM(theme.bgm)
      bgm.stream:play()
      bgm.id = theme.bgm
    elseif not theme and bgm.stream then
      bgm.stream:stop()
      bgm.stream = nil
    end
  end

end

return SoundTrack

