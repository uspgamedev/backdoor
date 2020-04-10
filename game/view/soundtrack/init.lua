
local Class   = require "steaming.extra_libs.hump.class"
local Util    = require "steaming.util"
local RES     = require 'resources'
local PROFILE = require 'infra.profile'
local ELEMENT = require "steaming.classes.primitives.element"

local _soundtrack
local funcs = {}

local SoundTrack  = Class {
  __includes = { ELEMENT }
}

--Consts
local _FADE_RATIO = 1

--Forward functions declarations
local fadeToVolume

function SoundTrack:init()
  self.theme = nil
  self.streams = {}

  ELEMENT.setId(self, "soundtrack")
  self.exception = true
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
    else
      error("theme isn't singletrack nor multitrack")
    end


    self:resumeTheme()
  end

end

function SoundTrack:enableTrack(track)
  if self.streams[track] then
    self.streams[track].active = true
  else
    error("not a valid track for current theme: ".. track)
  end
end

function SoundTrack:disableTrack(track)
  if self.streams[track] then
    self.streams[track].active = false
  else
    error("not a valid track for current theme: ".. track)
  end

end

function SoundTrack:resumeTheme()
  for _, stream in pairs(self.streams) do
    stream.source:setVolume(0)
    stream.source:play()
  end
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

function SoundTrack:update(dt)
  for _, stream in pairs(self.streams) do
    if stream.active then
      fadeToVolume(stream.source, PROFILE.getPreference("bgm-volume") / 100, dt)
    else
      fadeToVolume(stream.source, 0, dt)
    end
  end
end

--Hard set the volume of active tracks to current bgm volume profile preference
function SoundTrack:setVolumeToPreference()
  for _, stream in pairs(self.streams) do
    if stream.active then
      stream.source:setVolume(PROFILE.getPreference("bgm-volume") / 100)
    end
  end
end

--Local functions

function fadeToVolume(source, target_vol, dt)
  local cur_vol = source:getVolume()

  source:setVolume(cur_vol + _FADE_RATIO*(target_vol - cur_vol)*dt)
end

--Module functions

function funcs.new()
  _soundtrack = SoundTrack()
  return _soundtrack
end

function funcs.get()
  return _soundtrack
end

function funcs.clear()
  _soundtrack:destroy()
  _soundtrack = nil
end

return funcs
