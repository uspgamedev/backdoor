-- PRIVATE VARIABLES --
local Menu = {}
local _registered = {}
local _count
local _current
local _size
local _actions = {
  confirm = false,
  cancel = false,
  next = false,
  prev = false,
}

-- PRIVATE METHODS --
-- get/set selection
local function _selection(n)
  _registered[_current] = n or _registered[_current]
  return _registered[_current]
end

-- check cancel
local function _checkCancel()
  return not _actions.cancel
end

-- check movement
local function _checkMovement()
  if _actions.next then _registered[_current] = _registered[_current] + 1 end
  if _actions.prev then _registered[_current] = _registered[_current] - 1 end
  return true
end

-- check if item was selected
local function _isSelected()
  return _count == _selection()
end

-- check if item was confirmed
local function _isConfirmed()
  return _isSelected() and _actions.confirm
end

-- start menu
function Menu.begin(name)
  -- register new menu
  if _current ~= name then
    _registered[name] = 1
    _current = name
    _count = 0
    _size = 0
  end

  -- check menu input and set menu box minimal dimensions
  return _checkCancel() and _checkMovement()
end

-- check menuitem
function Menu.item(item)
  -- increment item count
  _count = _count + 1
  return _isConfirmed()
end


function Menu.finish()
  -- update menu size
  _size = _count
  _count = 0

  -- reposition selection if out of bounds
  if _selection() > _size then _selection(1)
  elseif _selection() < 1 then _selection(_size) end

  -- reset actions' states
  for k in pairs(_actions) do _actions[k] = false end
  return _selection()
end

-- MENU ACTIONS --
function Menu.confirm() _actions.confirm = true end
function Menu.cancel() _actions.cancel = true end
function Menu.next() _actions.next = true end
function Menu.prev() _actions.prev = true end

-- GETTERS --
function Menu.getSelection ()
  -- currently selected index
  return _selection()
end

function Menu.getSize ()
  -- total number of items in menu
  return _size
end

return Menu

