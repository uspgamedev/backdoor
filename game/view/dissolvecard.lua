
local COLORS  = require 'domain.definitions.colors'
local PLAYSFX = require 'helpers.playsfx'
local RANDOM  = require 'common.random'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local Dissolve = Class{
  __includes = { ELEMENT }
}

local _MAX_OFFSET = 90
local _MAX_RADIUS = 300

function Dissolve:init(cardview, duration)
  ELEMENT.init(self)

  self.card = cardview
  self.radius = 0

  self.offset = 0

  self.duration = duration

  self.deferred = function () end

  --PLAYSFX 'dissolve' TODO add a sfx for this
  self:register('HUD_FX')

  self:addTimer(nil, MAIN_TIMER, "tween", 3*duration/4, self,
                { radius = _MAX_RADIUS }, 'in-quad')
  self:addTimer("start", MAIN_TIMER, "tween", duration, self,
                { offset = -_MAX_OFFSET }, 'in-quad',
                function () self:kill(); return self.deferred() end)
end

function Dissolve:andThen(deferred)
  self.deferred = deferred
end

function Dissolve:update(dt)
  self.card:setOffset(0, self.offset)
  self.card:setStencil(self:getStencilFunction())
end

function Dissolve:getStencilFunction()
  return function()
            local x, y = self.card:getPoint():unpack()
            love.graphics.circle("fill", x, y, self.radius)
         end
end

function Dissolve:draw()

end

return Dissolve
