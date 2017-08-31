
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
GS = {
    PLAY = require "gamestates.play",     --Game Gamestate
    PICK_TARGET = require "gamestates.pick_target", --Player is choosing targets
    START_MENU = require "gamestates.start_menu", --The game main menu
    USER_TURN = require "gamestates.user_turn", --User's turn
}

-- GAMESTATE SWITCHER
SWITCHER = require 'infra.switcher'

local PROFILE = require 'infra.profile'
local RUNFLAGS = require 'infra.runflags'

------------------
--LÖVE FUNCTIONS--
------------------

function love.load(arg)

    Setup.config() --Configure your game

    RUNFLAGS.init(arg)

    SWITCHER.init() --Overwrites love callbacks to call Gamestate as well

    PROFILE.init() -- initializes save & load system

    --[[
        Setup support for multiple resolutions. Res.init() Must be called after Gamestate.registerEvents()
        so it will properly call the draw function applying translations.
    ]]
    Res.init()

    require 'tests'

    SWITCHER.start(GS.START_MENU) --Jump to the inicial state

end

function love.quit()
  imgui.ShutDown();
  PROFILE.quit()
end
