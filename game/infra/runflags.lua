
local RUNFLAGS = {}
local _flags = {}

function RUNFLAGS.init(arg)
  for _, runflag in ipairs(arg) do
    if runflag:match("^%-") then
      local flagname = runflag:match("%-(%w+)")
      local value = runflag:match("=(.+)")
      value = tonumber(value) or value or true
      _flags[flagname:upper()] = value
    end
  end
  RUNFLAGS.init = function () end
end

return setmetatable(RUNFLAGS, {
  __index = function (t, k) return _flags[k] end
})
