
local Class = require "steaming.extra_libs.hump.class"
local RES = require 'resources'
local PROFILE = require 'infra.profile'

local SoundTrack  = Class({})

function SoundTrack:init()

  self.theme = nil
  self.streams = {}
end

function SoundTrack:playTheme(theme)
  if not theme then
    error("theme not provided to play")
  end

  if self.theme ~= theme then
    self:clearTheme()

    self.theme = theme

    if theme.singletrack then
      self.streams['default'] = {
        source = RES.loadBGM(theme.singletrack.bgm),
        active = true
      }
    elseif theme.multitrack then
      self.streams['default'] = {
        source = RES.loadBGM(theme.multitrack.default),
        active = true,
      }
      self.streams['danger'] = {
        source = RES.loadBGM(theme.multitrack.danger),
        active = false,
      }
      self.streams['focused'] = {
        source = RES.loadBGM(theme.multitrack.focused),
        active = false,
      }
    else
      error("theme isn't singletrack nor multitrack")
    end


    self:resumeTheme()
  end

end

function SoundTrack:enableTrack(track)
  if self.streams[track] then
    self.streams[track].active = true
    self:updateVolume()
  else
    error("not a valid track for current theme: ".. track)
  end
end

function SoundTrack:disableTrack(track)
  if self.streams[track] then
    self.streams[track].active = false
    self:updateVolume()
  else
    error("not a valid track for current theme: ".. track)
  end

end

function SoundTrack:resumeTheme()
  for _, stream in pairs(self.streams) do
    stream.source:play()
  end
  self:updateVolume()
end

function SoundTrack:stopTheme()
  for _, stream in pairs(self.streams) do
    stream.source:stop()
  end
end

function SoundTrack:clearTheme()
  self:stopTheme()
  self.streams = {}
end

function SoundTrack:updateVolume()
  for _, stream in pairs(self.streams) do
    if stream.active then
      stream.source:setVolume(PROFILE.getPreference("bgm-volume") / 100)
    else
      stream.source:setVolume(0)
    end
  end
end

return SoundTrack
