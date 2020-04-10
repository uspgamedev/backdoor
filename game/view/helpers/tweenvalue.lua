
local Deferred = require 'common.deferred'
local Class    = require "steaming.extra_libs.hump.class"
local ELEMENT  = require "steaming.classes.primitives.element"

local TweenValue = Class {
  __includes = { ELEMENT }
}

local _interpolators = {
  linear = function()
    return function(value, target, dt)
      if value < target then
        return math.min(value + dt, target)
      elseif value > target then
        return math.max(value - dt, target)
      else
        return value
      end
    end
  end,
  smooth = function(speed)
    return function(value, target, dt)
      return value + (target - value) * speed * dt
    end
  end
}

function TweenValue:init(value, interpolator_name, ...)
  ELEMENT.init(self)
  self.value = value
  self.target = value
  self.interpolator = _interpolators[interpolator_name or 'linear'](...)
  self.deferred = false
  self:setSubtype('task')
end

function TweenValue:update(dt)
  self.value = self.interpolator(self.value, self.target, dt)
  return self:checkCallback()
end

function TweenValue:checkCallback()
  if math.abs(self.value - self.target) <= math.max(0.01, self.target/100) then
    self.value = self.target
    if self.deferred then
      local deferred = self.deferred
      self.deferred = false
      deferred:trigger()
    end
  end
end

function TweenValue:set(target)
  self.target = target
  self.deferred = Deferred:new{}
  return self.deferred
end

function TweenValue:snap(value)
  self.value = value
  self.target = value
  return self:checkCallback()
end

function TweenValue:get()
  return self.value
end

return TweenValue

