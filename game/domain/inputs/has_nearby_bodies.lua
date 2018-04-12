
local DEFS = require 'domain.definitions'
local INPUT = {}

INPUT.schema = {
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'count', name = "At least", type = 'value', match = 'integer',
    range = {1} },
  { id = 'range', name = "Range", type = 'value', match = 'integer',
    range = {0} },
  { id = 'body-type', name = "Body Type", type = 'enum',
    options = 'domains.body' },
  { id = 'ignore-owner', name = "Ignore Owner", type = 'boolean' },
  { id = 'ignore-same-faction', name = "Ignore Same Faction",
    type = 'boolean' },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'none'

local function _checkOwner(actor, body, ignore)
  return not ignore or actor:getBody() ~= body
end

local function _checkFaction(actor, body, ignore)
  return not ignore or actor:getBody():getFaction() ~= body:getFaction()
end

function INPUT.isValid(actor, fieldvalues, value)
  local sector = actor:getBody():getSector()
  local i, j = unpack(fieldvalues['pos'])
  local range = fieldvalues['range']
  local specname = fieldvalues['body-type']
  local notowner = fieldvalues['ignore-owner']
  local notfaction = fieldvalues['ignore-same-faction']
  local count = 0
  for di=i-range,i+range do
    for dj=j-range,j+range do
      if di ~= i or dj ~= j then
        local body = sector:getBodyAt(di, dj)
        if body and body:isSpec(specname)
                and _checkOwner(actor, body, notowner)
                and _checkFaction(actor, body, notfaction) then
          count = count + 1
        end
      end
    end
  end
  return count >= fieldvalues['count']
end

return INPUT

