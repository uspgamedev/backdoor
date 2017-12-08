--MODULE FOR THE GAMESTATE: CHARACTER BUILDER--
local DB             = require 'database'
local INPUT          = require 'infra.input'
local CONTROLS       = require 'infra.control'
local CharaBuildView = require 'view.charabuild'


local state = {}

--CONSTS--
local _CONFIRM = 'CONFIRM'
local _CANCEL  = 'CANCEL'
local _NEXT    = 'RIGHT'
local _PREV    = 'LEFT'

--LOCAL VARIABLES--

local _playerinfo
local _view
local _menus
local _leave

--LOCAL FUNCTIONS--

local function _resetState()
  _playerinfo.species    = false
  _playerinfo.background = false
  _playerinfo.confirm    = false
end

--STATE FUNCTIONS--

function state:init()
  _playerinfo = {
    species    = false,
    background = false,
    confirm    = false,
  }
end

function state:enter()
  CONTROLS.setMap()
  _resetState()
  _view = CharaBuildView()
  _view:addElement("GUI", nil, "character_builder_view")
  _view:open(_playerinfo)
  _leave = false
end

function state:leave()
end

function state:update(dt)
  MAIN_TIMER:update(dt)

  if _leave then return end

  -- if you confirm or cancel, all it does is change the current menu context
  if INPUT.actionPressed(_CONFIRM) then
    _view:confirm()
  elseif INPUT.actionPressed(_CANCEL) then
    _view:cancel()
  elseif INPUT.actionPressed(_NEXT) then
    _view:selectNext()
  elseif INPUT.actionPressed(_PREV) then
    _view:selectPrev()
  end

  -- exit gamestate if either everything or nothing is done
  if _view.leave then
    _leave = true
    _view:close(function()
      _view:destroy()
      SWITCHER.pop()
    end)
  elseif _view:getContext() > 3 then
    if _playerinfo.confirm then
      _leave = true
      _view:close(function()
        _view:destroy()
        SWITCHER.pop(_playerinfo)
      end)
    else
      _resetState()
      _view:reset()
    end
  end
end

function state:draw()
  Draw.allTables()
end

return state

