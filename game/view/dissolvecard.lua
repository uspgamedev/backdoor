
local COLORS  = require 'domain.definitions.colors'
local PLAYSFX = require 'helpers.playsfx'
local RANDOM  = require 'common.random'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local Dissolve = Class{
  __includes = { ELEMENT }
}

local _MAX_OFFSET = 90
local _MAX_RADIUS = 100

function Dissolve:init(cardview, duration)
  ELEMENT.init(self)

  self.card = cardview
  self.radius_1 = 0
  self.radius_2 = 0
  self.radius_3 = 0

  self.offset = 0

  self.duration = duration

  self.deferred = function () end

  self:register('HUD_FX')

  PLAYSFX 'dissolve'
  self:addTimer("start", MAIN_TIMER, "tween", duration, self,
  { offset = -_MAX_OFFSET }, 'in-quad',
  function () self:kill(); return self.deferred() end)

  --Create "dissolve" effect
  local d = 2*self.duration/4
  self:addTimer(nil, MAIN_TIMER, "tween", d, self,
                { radius_1 = _MAX_RADIUS }, 'in-quad')

  self:addTimer(nil, MAIN_TIMER, "after", d/6,
                function()
                  self:addTimer(nil, MAIN_TIMER, "tween", 4*d/5, self,
                                { radius_2 = _MAX_RADIUS }, 'in-quad')
                end)
  self:addTimer(nil, MAIN_TIMER, "after", 2*d/5,
                function()
                  self:addTimer(nil, MAIN_TIMER, "tween", 3*d/5, self,
                                { radius_3 = _MAX_RADIUS }, 'in-quad')
                end)
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
            love.graphics.circle("fill", x + 5, y - 5, self.radius_1)
            love.graphics.circle("fill", x - 15, y - 30, self.radius_2)
            love.graphics.circle("fill", x - 20, y + 25, self.radius_3)
         end
end

function Dissolve:draw()

end

return Dissolve
