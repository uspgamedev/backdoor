local INPUT = require 'input'
local Util  = require "steaming.util"
local Draw  = require "draw"

local state = {}

--[[ LOCAL VARIABLES ]]--

local _view
local _alert

--[[ LOCAL FUNCTIONS ]]--

--[[ STATE FUNCTIONS ]]--

function state:init()
  -- dunno
end

function state:enter(_, view, animation)

  _view = view
  _alert = false

end

function state:leave()

  Util.destroyAll()

end

function state:update(dt)

  if INPUT.wasAnyPressed(0.5) then
    _alert = true
  end

  if not _view.sector:hasPendingVFX() then
    SWITCHER.pop(_alert)
  else
    _view.sector:updateVFX(dt)
  end

end

function state:draw()

    Draw.allTables()

end

return state

