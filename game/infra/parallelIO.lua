
local JSON    = require "dkjson"
local Promise = require "common/promise"

local ParallelIO = {}

--- Creates a new thread to write in
function ParallelIO.new()
  local promise = Promise()

  

  return promise
end

--- Writes to a file in a different thread
-- @tparam filename string Relative path to file from the user directory
-- @tparam data 
function ParallelIO.writeTo(filename, data, encoding)
end

return ParallelIO

