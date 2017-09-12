--MODULE FOR THE GAMESTATE: CHARACTER BUILDER--
local DB = require 'database'
local MENU = require 'infra.menu'
local CONTROLS = require 'infra.control'
local CharaBuildView = require 'domain.view.charabuildview'


local state = {}

--LOCAL VARIABLES--

local _mapping
local _context
local _current
local _confirm
local _playerinfo
local _view
local _schemas

--LOCAL FUNCTIONS--

local function _initSchemas()
  local actors_schemas = DB.loadDomain("actor")
  local body_schemas = DB.loadDomain("body")
  local schemas = {}

  schemas.race = {}
  schemas.background = {}

  for bgname, actor in pairs(actors_schemas) do
    if actor.behavior == "player" then
      schemas.background[bgname] = actor
    end
  end

  for racename, body in pairs(body_schemas) do
    schemas.race[racename] = body
  end

  return schemas
end

local function _resetState()
  _playerinfo.race = false
  _playerinfo.background = false
  _current = _current == 1 and 0 or 1
  _view:flush()
end

--STATE FUNCTIONS--

function state:init()
  _mapping = {
    PRESS_CONFIRM = MENU.confirm,
    PRESS_CANCEL  = MENU.cancel,
    PRESS_LEFT    = MENU.prev,
    PRESS_RIGHT   = MENU.next,
  }
  _contexts = {"Race", "Background", "Are you sure?"}
  _confirm = {"Yes", "No"}
  _schemas = _initSchemas()
  _view = CharaBuildView()
end

function state:enter()
  _current = 1
  _playerinfo = {bg = false, race = false}

  CONTROLS.setMap(_mapping)

  _view:addElement("HUD", nil, "character_builder_view")
end

function state:leave()
  CONTROLS.setMap()
  _view:flush()
  _view:destroy()
end

function state:update(dt)
  local context_name = _contexts[_current]
  if MENU.begin(context_name) then
    _view:setContext(context_name)
    if context_name == "Are you sure?" then
      for _,yn in ipairs(_confirm) do
        _view:setItem(yn)
        if MENU.item(yn) then
          if yn == "Yes" then
            _current = _current + 1
            _view:flush()
          elseif yn == "No" then
            _resetState()
          end
        end
      end
    else
      for name, schema in pairs(_schemas[context_name:lower()]) do
        _view:setItem(name, schema)
        if MENU.item(name) then
          _view:save(context_name, name)
          _playerinfo[context_name:lower()] = name
          _current = _current + 1
        end
      end
    end
  else
    _resetState()
  end
  _view:select(MENU.finish())
  MENU.flush()
  if _current == 0 then SWITCHER.pop() end
  if _current > 3 then SWITCHER.pop(_playerinfo) end
end

function state:draw()
  Draw.allTables()
end

return state

