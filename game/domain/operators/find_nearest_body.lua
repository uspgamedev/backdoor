
local OP = {}

OP.schema = {
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'range', name = "Range", type = 'value', match = 'integer',
    range = {0} },
  { id = 'ignore-owner', name = "Ignore Owner", type = 'boolean' },
  { id = 'ignore-same-faction', name = "Ignore Same Faction",
    type = 'boolean' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'body'

local function _checkOwner(actor, body, ignore)
  return not ignore or actor:getBody() ~= body
end

local function _checkFaction(actor, body, ignore)
  return not ignore or actor:getBody():getFaction() ~= body:getFaction()
end

function OP.preview(_, fieldvalues)
  local pos = fieldvalues['pos']
  local range = fieldvalues['range']
  return ("nearest target within %d tiles of %s"):format(range, pos)
end

function OP.process(actor, fieldvalues)
  local sector = actor:getBody():getSector()
  local i, j = unpack(fieldvalues['pos'])
  local range = fieldvalues['range']
  local notowner = fieldvalues['ignore-owner']
  local notfaction = fieldvalues['ignore-same-faction']
  local nearest
  local mindist = range+1
  for di=i-range,i+range do
    for dj=j-range,j+range do
      if di ~= i or dj ~= j then
        local body = sector:getBodyAt(di, dj)
        local dist = math.max(math.abs(di-i), math.abs(dj-j))
        if body and dist < mindist and _checkOwner(actor, body, notowner)
                and _checkFaction(actor, body, notfaction) then
          nearest = body
          mindist = dist
        end
      end
    end
  end
  return nearest
end

return OP

