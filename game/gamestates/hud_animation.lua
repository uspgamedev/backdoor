local state = {}
local Util  = require "steaming.util"
local Draw  = require "draw"

--[[ LOCAL VARIABLES ]]--

local _action_hud
local _already_activated

--[[ LOCAL FUNCTIONS ]]--

--[[ STATE FUNCTIONS ]]--

function state:enter(_, action_hud)

  _action_hud = action_hud
  if _action_hud:getHandView():isActive() then
    _already_activated = true
  else
    _already_activated = false
    _action_hud:getHandView():activate()
  end

end

function state:leave()

  if not _already_activated then
    _action_hud:getHandView():deactivate()
  end
  _action_hud = false
  Util.destroyAll()

end

function state:update(dt)

  if not _action_hud or not _action_hud:isAnimating() then
    SWITCHER.pop()
  end
  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

return state
