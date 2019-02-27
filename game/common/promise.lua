
local Promise = Class({})

function Promise:init()
  self.fulfillCallback = nil
  self.rejectCallback = nil
end

function Promise:fulfill(...)
  assert(type(self.fulfillCallback) == "function", "Unhandled Promise fulfillment.")

  return self.fulfillCallback(...)
end

function Promise:reject(...)
  assert(type(self.rejectCallback) == "function", "Unhandled Promise rejection.")

  return self.rejectCallback(...)
end

function Promise:onFulfill(callback)
  assert(type(callback) == "function", "Cannot assign fulfill callback that is not a function")
  self.fulfillCallback = callback
  return self
end

function Promise:onReject(callback)
  assert(type(callback) == "function", "Cannot assign reject callback that is not a function")
  self.rejectCallback = callback
  return self
end

return Promise

