
--[[ CARDVIEW PROPERTIES ]]--

local _ACTION_TYPES = {
  'get', 'consume'
}

--PackView Class--

local PackView = Class{
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function PackView:init(actor)

  ELEMENT.init(self)

  self.focus_index = 1 --What card is focused. -1 if none
  self.action_type = 1
  self.actor = actor
  self.pack = {}

  for _,card_specname in actor:iteratePack() do
    table.insert(self.pack, { specname = card_specname })
  end

end

function PackView:removeCurrent()
  table.remove(self.pack, self.focus_index)
  self.focus_index = math.min(self.focus_index, #self.pack)
end

function PackView:isEmpty()
  return #self.pack == 0
end

function PackView:getFocus()
  return self.focus_index
end

function PackView:moveFocus(dir)
  if dir == "left" then
    self.focus_index = math.max(1, self.focus_index - 1)
  elseif dir == "right" then
    self.focus_index = math.min(#self.pack, self.focus_index + 1)
  end
end

function PackView:getActionType()
  return _ACTION_TYPES[self.action_type]
end

function PackView:changeActionType(dir)
  local N = #_ACTION_TYPES
  if dir == 'up' then
    self.action_type = (self.action_type - 2)%N + 1
  elseif dir == 'down' then
    self.action_type = self.action_type%N + 1
  else
    error(("Unknown dir %s"):format(dir))
  end
end

function PackView:draw()
  local x, y = 800,400
  local g = love.graphics
  local card = self.pack[self.focus_index]
  if card then
    local view = ("%s [%d/%d]"):format(card.specname, self.focus_index,
                                       #self.pack)
    g.print(view, x, y)
    g.print(_ACTION_TYPES[self.action_type], x, y + 50)
  end
end

return PackView

