
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

  SWITCHER.start(GS.START_MENU) --Jump to the initial state

  if RUNFLAGS.DEVELOPMENT then
    local GUI = require 'devmode.gui'
    GUI():register("GUI", nil, 'devmode-gui')
  end

  setmetatable(_G, {
    __newindex = function(_, k, _)
      return error(_globalvar_err:format(k, debug.traceback()))
    end
  })
end

--local SAMPLES = 10
--local profiling = {}
--local last_state
--
--function updateProfiling(dt)
--  local state = last_state
--  last_state = SWITCHER.current()
--  if not state then return end
--  local name = "???"
--  for k,v in pairs(GS) do
--    if v == state then
--      name = k
--      break
--    end
--  end
--  if dt > 0.2 then
--    print("lag on state", name)
--  end
--  local sample = profiling[name] or { times = {} , n = 1 }
--  sample.times[sample.n] = dt
--  sample.n = (sample.n % SAMPLES) + 1
--  profiling[name] = sample
--end
--
--function average(sample)
--  local sum = 0
--  for _,time in ipairs(sample.times) do
--    sum = sum + time
--  end
--  return sum / math.max(#sample.times, SAMPLES)
--end

function love.update(dt)
  MAIN_TIMER:update(dt)
  if INPUT.wasActionReleased('QUIT') then
    love.event.quit()
  elseif INPUT.wasActionPressed('DEVMODE') and not DEBUG
                                           and RUNFLAGS.DEVELOPMENT then
    DEBUG = true
    local current = SWITCHER.current()
    if current.devmode then current:devmode() end
    SWITCHER.push(GS.DEVMODE)
  end
  SWITCHER.update(dt)
  --updateProfiling(dt)
  INPUT.flush() -- must be called afterwards
  Util.updateSubtype(dt, 'task')
  Draw.update(dt)
  SOUNDTRACK:update(dt)
  Util.destroyAll()
end

function love.draw()
  SWITCHER.draw()
  --local g = love.graphics
  --g.push()
  --g.origin()
  --g.setColor(1,1,1)
  --local i = 0
  --for name,sample in pairs(profiling) do
  --  g.print(("%s: %.2f"):format(name, 1 / average(sample)), 32, 32+i*32)
  --  i = i + 1
  --end
  --g.pop()
end

function love.quit()
  if RUNFLAGS.DEVELOPMENT then
    Util.findId('devmode-gui'):destroy()
    imgui.ShutDown();
  end
  PROFILE.quit()
end
