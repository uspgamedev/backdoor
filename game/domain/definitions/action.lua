
local ACTION = {}

function ACTION.unpack(slot)
  local kind, index = slot:match("^(%w+)/(%d+)$")
  kind = kind or slot
  return kind, index
end

return ACTION

