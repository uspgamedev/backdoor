
local JSON = require 'dkjson'
local KEYORDER = require 'common.keyorder'

local fs = love.filesystem

return function()
  local basepath = "database/domains/card"
  local files = fs.getDirectoryItems(basepath, {type = "file"})
  for _,filename in ipairs(files) do
    local filepath = basepath.."/"..filename
    local filedata = assert(fs.newFileData(filepath))
    local input = JSON.decode(filedata:getString())
    KEYORDER.setOrderedKeys(input)
    local file = assert(io.open(("%s/%s"):format(fs.getSource(), filepath)))
    file:write(JSON.encode(input, { indent = true }))
    file:close()
  end
end

