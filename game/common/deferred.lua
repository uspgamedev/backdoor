
local Deferred = require 'lux.prototype' :new{
  callback = false
}

function Deferred:andThen(callback)
  self.callback = callback
end

function Deferred:trigger(...)
  if self.callback then
    self.callback(...)
    self.callback = false
  end
end

return Deferred

