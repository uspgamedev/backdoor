
local state = {}

--[[ LOCAL VARIABLES ]]--

local _hud_animator
local _already_activated

--[[ LOCAL FUNCTIONS ]]--

--[[ STATE FUNCTIONS ]]--

function state:enter(_, hud_animator)

  _hud_animator = hud_animator
  if _hud_animator:getHandView():isActive() then
    _already_activated = true
  else
    _already_activated = false
    _hud_animator:getHandView():activate()
  end

end

function state:leave()

  if not _already_activated then
    _hud_animator:getHandView():deactivate()
  end
  _hud_animator = false
  Util.destroyAll()

end

function state:update(dt)

  if not _hud_animator or not _hud_animator:isAnimating() then
    SWITCHER.pop()
  end
  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

return state

