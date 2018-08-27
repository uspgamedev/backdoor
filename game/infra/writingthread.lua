
local JSON = require 'dkjson'
local filesystem = love.filesystem

local function _compress(str) --> str
  return assert(ZIP.compress(str:gsub(" ", ""), "lz4", 9))
end

local function _encode(t, compress) --> str
  local encoded = JSON.encode(t, {indent = true})
  if compress then
    encoded = _compress(encoded)
  end
  return encoded
end

local function _writeData(filepath, data, compress)
  local file = assert(filesystem.newFile(filepath, "w"))
  file:write(_encode(data, compress))
  return file:close()
end

local _channel = love.thread.getChannel('write_data')

while true do
  local msg = _channel:pop()
  if msg then
    if msg.die then break end
    _writeData(msg.filepath, msg.data, msg.compress)
    collectgarbage() -- free channel data, according to documentation
  end
end

