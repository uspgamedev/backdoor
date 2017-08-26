--MODULE FOR SETUP STUFF--

local setup = {}

--------------------
--SETUP FUNCTIONS
--------------------

--Set game's global variables, random seed, window configuration and anything else needed
function setup.config()

    VERSION = "0.0.4"

    --RANDOM SEED--
    love.math.setRandomSeed( os.time() )

    --TIMERS--
    MAIN_TIMER = Timer.new()  --General Timer


    --GLOBAL VARIABLES--
    DEBUG = false --DEBUG mode status

    O_WIN_W = 1280 --The original width of your game. Work with this value when using res_manager multiple resolutions support
    O_WIN_H = 720  --The original height of your game. Work with this value when using res_manager multiple resolutions support

    --INITIALIZING TABLES--
    --Drawing Tables
    DRAW_TABLE = {
        BG  = {}, --Background (bottom layer, first to draw)
        L1  = {}, --Layer 1
        L2  = {}, --Layer 2
        HUD = {}, --HUD (top layer, second to last to draw)
        GUI = {}, --Graphic User Interface (top layer, last to draw)
    }
    --Other Tables
    SUBTP_TABLE = {} --Table with tables for each subtype (for fast lookup)
    ID_TABLE = {} --Table with elements with Ids (for fast lookup)

    --CAMERA--
    CAM = Camera(O_WIN_W/2, O_WIN_H/2) --Set camera position to center of screen

    --IMAGES--
    IMG = { --Table containing all the images
    }

    --AUDIO--
    SFX = { --Table containing all the sound fx
    }

    BGM = { --Table containing all the background music tracks
    }

    --SHADERS--
        --

end

--Return functions
return setup
