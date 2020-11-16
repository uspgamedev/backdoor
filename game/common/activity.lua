
-- local _activity = Activity()
-- function _activity:doSomething(x, y)
--   x = x + 1
--   self.wait(tween(...))
--   y = y + 1
-- end
--
-- _activity:doSomething(42, 1337)

local Task = require 'lux.class' :new{}

require 'lux.portable'

local coroutine = coroutine
local debug     = debug
local error     = error
local table     = table
local setfenv   = setfenv

function Task:instance (obj, func, ...)

  setfenv(1, obj)

  local function _bootstrap(...)
    return func(...)
  end

  local task = coroutine.create(_bootstrap)
  local onhold = false
  local params = {}

  local function _hold()
    onhold = true
  end

  local function _release(...)
    onhold = false
    params = table.pack(...)
  end

  function resume(...)
    local check, result = coroutine.resume(task, obj, ...)
    if not check then
      error(debug.traceback(task, result))
    end
    return result
  end

  function done()
    return coroutine.status(task) == 'dead'
  end

  function wait(deferred)
    if deferred and deferred.andThen then
      deferred:andThen(resume)
    end
    return coroutine.yield(obj)
  end

  function __operator:newindex()
    return error("Do not change the task object")
  end

end

local Activity = require 'lux.class' :new{}

function Activity:instance(obj)

  setfenv(1, obj)

  local _funcs = {}

  function __operator:newindex(name, func)
    _funcs[name] = func
  end

  function __operator:index(name)
    local newtask = Task(_funcs[name])
    return function (_, ...) return newtask.resume(...) end
  end

end

return Activity

