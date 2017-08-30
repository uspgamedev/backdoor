--DEPENDENCIES--
local Queue = require 'lux.common.Queue'


--PRIVATE--
local REDIRECT = {
  __index = function (self, k)
    if k == "RELEASE_QUIT" then love.event.quit() end
    return function () end
  end
}

local Controls = {}

local _mapped_controls = {}
local _inputs = Queue(64)


--PUBLIC--
function Controls.enqueue (control)
  _inputs.push(control)
end

function Controls.flush ()
  _inputs.popAll()
end

function Controls.setMap (m)
  _mapped_controls = setmetatable(m or {}, REDIRECT)
end

function Controls.getMap()
  return _mapped_controls
end

function Controls.update ()
  while not _inputs.isEmpty() do
    _mapped_controls[_inputs.pop()]()
  end
end

Controls.setMap(_mapped_controls)
return Controls

