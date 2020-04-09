
-- FIXME
-- luacheck: no global

-- set libs dir to path
require 'libs'

-- LUX portability
require 'lux.portable'

local common = require 'lux.common'

printf = common.printf
identityp = common.identityp

-- CPML
cpml      = require 'cpml'

local Res        = require "steaming.res_manager"
local Setup      = require "setup"
local Draw       = require "draw"
local Util       = require "steaming.util"
local SoundTrack = require 'view.soundtrack'

-- GAMESTATES
GS = require 'gamestates'

-- GAMESTATE SWITCHER
SWITCHER = require 'infra.switcher'

local PROFILE  = require 'infra.profile'
local RUNFLAGS = require 'infra.runflags'
local INPUT    = require 'input'
local DB       = require 'database'
local GUI

local SOUNDTRACK

local _globalvar_err = [=[

HOW DARE YOU CREATE THE GLOBAL VARIABLE `%s`
HERE IS WHERE YOU DID IT, MORTAL:
%s

]=]
------------------
--LÖVE FUNCTIONS--
------------------

function love.load(arg)

  DEVELOPMENT = false

  if DEVELOPMENT then
    GUI = require 'devmode.gui'
  end

  Setup.config() --Configure your game

  RUNFLAGS.init(arg)

  SWITCHER.init() --Overwrites love callbacks to call Gamestate as well

  -- Setup support for multiple resolutions. Res.init() Must be called after
  -- Gamestate.registerEvents() so it will properly call the draw function
  -- applying translations.
  Res.init()
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- init DB
  DB.init()

  -- initializes save & load system
  PROFILE.init()

  -- initializes soundtrack singleton
  SOUNDTRACK = SoundTrack.new()

  require 'tests'

  SWITCHER.start(GS.START_MENU) --Jump to the inicial state

  if DEVELOPMENT and GUI then
    GUI():register("GUI", nil, 'devmode-gui')
  end

  setmetatable(_G, {
    __newindex = function(_, k, _)
      return error(_globalvar_err:format(k, debug.traceback()))
    end
  })
end

function love.update(dt)
  MAIN_TIMER:update(dt)
  if INPUT.wasActionReleased('QUIT') then
    love.event.quit()
  elseif INPUT.wasActionPressed('DEVMODE') and not DEBUG and DEVELOPMENT then
    DEBUG = true
    local current = SWITCHER.current()
    if current.devmode then current:devmode() end
    SWITCHER.push(GS.DEVMODE)
  end
  SWITCHER.update(dt)
  INPUT.flush() -- must be called afterwards
  Util.updateSubtype(dt, 'task')
  Draw.update(dt)
  SOUNDTRACK:update(dt)
  Util.destroyAll()
end

function love.draw()
  SWITCHER.draw()
end

function love.quit()
  if DEVELOPMENT then
    Util.findId('devmode-gui'):destroy()
    imgui.ShutDown();
  end
  PROFILE.quit()
end
