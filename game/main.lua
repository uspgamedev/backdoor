
-- set libs dir to path
require 'libs'

-- LUX portability
require 'lux.portable'

local common = require 'lux.common'

printf = common.printf
identityp = common.identityp

-- CPML
cpml      = require 'cpml'

-- HUMP
Timer     = require "steaming.extra_libs.hump.timer"
Class     = require "steaming.extra_libs.hump.class"
Camera    = require "steaming.extra_libs.hump.camera"
Vector    = require "steaming.extra_libs.hump.vector"
Signal    = require "steaming.extra_libs.hump.signal"


-- CLASSES
require "steaming.classes.primitive"

-- STEAMING MODULES
Util      = require "steaming.util"
Font      = require "steaming.font"
Res       = require "steaming.res_manager"

Draw      = require "draw"
Setup     = require "setup"

-- GAMESTATES
GS = require 'gamestates'

-- GAMESTATE SWITCHER
SWITCHER = require 'infra.switcher'

local PROFILE = require 'infra.profile'
local RUNFLAGS = require 'infra.runflags'
local INPUT = require 'input'
local DB = require 'database'

local JSON = require 'dkjson'

------------------
--LÖVE FUNCTIONS--
------------------

function love.load(arg)

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

  require 'tests'

  SWITCHER.start(GS.START_MENU) --Jump to the inicial state
end

function love.update(dt)
  MAIN_TIMER:update(dt)
  if INPUT.wasActionReleased('QUIT') then love.event.quit() end
  SWITCHER.update(dt)
  INPUT.flush() -- must be called afterwards
  Draw.update(dt)
end

function love.draw()
  SWITCHER.draw()
end

function love.quit()
  imgui.ShutDown();
  PROFILE.quit()
end

