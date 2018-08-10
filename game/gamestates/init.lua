
local GAMESTATES = {}

local fs = love.filesystem

for _,filename in ipairs(fs.getDirectoryItems("gamestates")) do
  local basename = filename:match("^(.-)[.]lua$")
  if basename and basename ~= "init" then
    local requirepath = "gamestates." .. basename
    GAMESTATES[basename:upper()] = require(requirepath)
  end
end

return GAMESTATES

