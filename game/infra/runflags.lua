
local RUNFLAGS = {}
local _flags = {}

function RUNFLAGS.init(arg)
  for _, runflag in ipairs(arg) do
    if runflag:match("^%-") then
      _flags[runflag:match("[^%-]+"):upper()] = true
    end
  end
  RUNFLAGS.init = function () end
end

return setmetatable(RUNFLAGS, {
  __index = function (t, k) return _flags[k] end
})
