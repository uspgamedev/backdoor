
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DEFS = require 'domain.definitions'
local ManageBufferView = require 'view.cardlist'

local state = {}

local _view
local _leave

local function _prev()
  _view:selectPrev()
end

local function _next()
  _view:selectNext()
end

local function _confirm()
  if not _view:isLocked() then _leave = true end
end

local function _cancel()
  if not _view:isLocked() then _leave = true end
end

function state:enter(from, actor)
  _view = ManageBufferView("SPECIAL")
  if actor:getBackBufferSize() > 0 then
    _leave = false
    _view:addElement("HUD")
    _view:open(actor:copyBackBuffer())
  else
    _leave = true
  end
end

function state:leave()
  _view:close()
  _view = nil
end

function state:update(dt)
  if DEBUG then return end

  MAIN_TIMER:update(dt)

  if _leave or _view:isCardListEmpty() then
    SWITCHER.pop({consumed = _view:getConsumeLog()})
  else

    local axis = DIRECTIONALS.getFromAxes()
    local hat = DIRECTIONALS.getFromHat()
    local input_dir = axis or hat
    if INPUT.wasActionPressed('LEFT') or input_dir == 'left' then
      _prev()
    elseif INPUT.wasActionPressed('RIGHT') or input_dir == 'right' then
      _next()
    elseif INPUT.wasActionPressed('CONFIRM') then
      _confirm()
    elseif INPUT.wasActionPressed('CANCEL') then
      _cancel()
    end

  end

end

function state:draw()
  Draw.allTables()
end

return state



