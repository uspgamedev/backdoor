
-- IMGUI
imgui     = require 'imgui'

-- IMGUI
cpml      = require 'cpml'

-- HUMP
Gamestate = require "steaming.extra_libs.hump.gamestate"
Timer     = require "steaming.extra_libs.hump.timer"
Class     = require "steaming.extra_libs.hump.class"
Camera    = require "steaming.extra_libs.hump.camera"
Vector    = require "steaming.extra_libs.hump.vector"


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
    --MENU     = require "gamestates.menu",     --Menu Gamestate
    PLAY     = require "gamestates.play",     --Game Gamestate
    --GAMEOVER = require "gamestates.gameover"  --Gameover Gamestate
}

------------------
--LÖVE FUNCTIONS--
------------------

function love.load(arg)

    Setup.config() --Configure your game

    Gamestate.registerEvents() --Overwrites love callbacks to call Gamestate as well

    --[[
        Setup support for multiple resolutions. Res.init() Must be called after Gamestate.registerEvents()
        so it will properly call the draw function applying translations.
    ]]
    Res.init()

    Gamestate.switch(GS.PLAY) --Jump to the inicial state

end

function love.quit()
  imgui.ShutDown();
end

