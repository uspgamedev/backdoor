
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
      self.streams['default'] = RES.loadBGM(theme.singletrack.bgm)
    elseif theme.multitrack then
      self.streams['default'] = RES.loadBGM(theme.multitrack.default)
      self.streams['danger'] = RES.loadBGM(theme.multitrack.danger)
      self.streams['focused'] = RES.loadBGM(theme.multitrack.focused)
    else
      error("theme isn't singletrack nor multitrack")
    end

    self:playTrack("default")

    self:updateVolume()
  end

end

function SoundTrack:playTrack(track)
  if self.streams[track] then
    self.streams[track]:play()
  else
    error("not a valid track for current theme: ".. track)
  end
end

function SoundTrack:stopTrack(track)
  if self.streams[track] then
    self.streams[track]:stop()
  else
    error("not a valid track for current theme: ".. track)
  end
end

function SoundTrack:stopTheme()
  for _, stream in pairs(self.streams) do
    stream:stop()
  end
end

function SoundTrack:clearTheme()
  self:stopTheme()
  self.streams = {}
end

function SoundTrack:updateVolume()
  for _, stream in pairs(self.streams) do
    stream:setVolume(PROFILE.getPreference("bgm-volume") / 100)
  end
end

return SoundTrack
