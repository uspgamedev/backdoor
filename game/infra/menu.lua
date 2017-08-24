
local Queue = require 'lux.common.Queue'

local Menu = {}

local _registered = {}
local _scroll_interval
local _scroll_top
local _count
local _current
local _size
local _width, _height
local _itemqueue = Queue(64)
local _renderqueue = Queue(64)
local _font = love.graphics.newFont(16)
local _actions = {
  confirm = false,
  cancel = false,
  next = false,
  prev = false,
}

-- padding, lineheight
local PD, LH = 16, 24

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

-- check height
local function _checkDimensions ()
  _width = math.max(_width, 2*PD)
  if _scroll_interval then _height = _scroll_interval*LH + 2*PD
  else _height = PD end
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

-- updates scrolling
local function _updateScroll()
  if _scroll_interval then
    if _scroll_top > _selection() then
      _scroll_top = _selection()
    elseif _selection - _scroll_top > _scroll_interval then
      _scroll_top = _selection - _scroll_top
    end
  end
end

-- start menu
function Menu.begin(name, x, y, scroll, static_width)
  -- register new menu
  if _current ~= name then
    _registered[name] = 1
    _current = name
    _scroll_interval = scroll
    _scroll_top = 1
    _count = 0
    _size = 0
    _width, _height = static_width or 0, 0
  end

  -- push menu position
  _renderqueue.push { "translate", x or 0, y or 0 }

  -- check menu input and set menu box minimal dimensions
  return _checkCancel() and _checkMovement() and _checkDimensions()
end

-- check menuitem
function Menu.item(item)
  -- increment item count
  _count = _count + 1

  -- update width to match max item width
  _width = math.max(_width, _font:getWidth(item))

  -- scroll item in limitted box
  if not _scroll_interval or _count >= _scroll_top
    and _count <= _scroll_top + _scroll_interval then

    -- check if selected
    if _count == _selection() then
      -- set to look bright if selected
      _itemqueue.push { "setColor", 0xff, 0xff, 0xff, 0xff }
    else
      -- set to look faded if not selected
      _itemqueue.push { "setColor", 0x80, 0x80, 0x80, 0x80 }
    end

    -- push item to item queue
    _itemqueue.push { "print", item, PD, _height }

    -- update height
    _height = _height + LH + PD
  end

  return _isConfirmed()
end


function Menu.finish()
  -- update menu size
  _size = _count
  _count = 0

  -- reposition selection if out of bounds
  if _selection() > _size then _selection(1)
  elseif _selection() < 1 then _selection(_size) end

  -- update scrolling, if there is any
  _updateScroll()

  -- draw menu container
  _renderqueue.push { "setColor", 0x20, 0x20, 0x20, 0xff }
  _renderqueue.push { "rectangle", "fill", 0, 0, _width, _height }

  -- push items to render queue
  while not _itemqueue.isEmpty() do
    _renderqueue.push(_itemqueue.pop())
    _renderqueue.push(_itemqueue.pop())
  end

  -- reset actions' states
  for k in pairs(_actions) do _actions[k] = false end
end

-- menu actions
function Menu.confirm() _actions.confirm = true end
function Menu.cancel() _actions.cancel = true end
function Menu.next() _actions.next = true end
function Menu.prev() _actions.prev = true end

-- getters
function Menu.getRenderQueue ()
  -- render queue
  return _renderqueue
end

function Menu.getSelection ()
  -- currently selected index
  return _selection()
end

function Menu.getSize ()
  -- total number of items in menu
  return _size
end

function Menu.hasItemsAbove ()
  -- if you can scroll up
  return _scroll_interval and _scroll_top > 1
    and _scroll_top - 1
end

function Menu.hasItemsBelow ()
  -- if you can scroll down
  return _scroll_interval and _scroll_top < _size - _scroll_interval
    and _size - _scroll_top - _scroll_interval
end

return Menu
