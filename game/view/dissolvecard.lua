
local COLORS  = require 'domain.definitions.colors'
local PLAYSFX = require 'helpers.playsfx'
local RANDOM  = require 'common.random'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local Dissolve = Class{
  __includes = { ELEMENT }
}

local _DURATION = .3
local _MAX_OFFSET = 90
function Dissolve:init(cardview)
  ELEMENT.init(self)

  self.card = cardview
  self.alpha = 1

  self.offset = 0

  self.deferred = function () end

  --PLAYSFX 'dissolve' TODO add a sfx for this
  self:register('HUD_FX')

  self:addTimer(nil, MAIN_TIMER, "tween", _DURATION, self,
                { offset = -_MAX_OFFSET }, 'out-quad')
  self:addTimer("start", MAIN_TIMER, "tween", _DURATION, self,
                { alpha = 0 }, 'in-back',
                function () self:kill(); return self.deferred() end)
end

function Dissolve:andThen(deferred)
  self.deferred = deferred
end

function Dissolve:update(dt)
  self.card:setOffset(0, self.offset)
  self.card:setEffectAlpha(self.alpha)
end

function Dissolve:draw()

end

return Dissolve
