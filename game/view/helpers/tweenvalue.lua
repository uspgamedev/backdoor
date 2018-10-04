
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
  self.callback = false
  self.callback_once = false
  self:setSubtype('frontend-hud')
end

function TweenValue:update(dt)
  self.value = self.interpolator(self.value, self.target, dt)
  return self:checkCallback()
end

function TweenValue:checkCallback()
  if math.abs(self.value - self.target) <= 0.01 then
    self.value = self.target
    if self.callback then
      self.callback()
      if self.callback_once then
        self.callback = false
        self.callback_once = false
      end
    end
  end
end

function TweenValue:set(target)
  self.target = target
end

function TweenValue:snap(value)
  self.value = value
  self.target = value
  return self:checkCallback()
end

function TweenValue:get()
  return self.value
end

function TweenValue:defer(callback, once)
  self.callback = callback
  self.callback_once = once
end

return TweenValue

