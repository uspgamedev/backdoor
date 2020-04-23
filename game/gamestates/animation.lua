
local SWITCHER = require 'infra.switcher'
local INPUT = require 'input'
local Util  = require "steaming.util"
local Draw  = require "draw"
local ANIMATIONS = require 'lux.pack' 'gamestates.animations'

local state = {}

--[[ LOCAL VARIABLES ]]--

local _animation_task
local _view
local _alert

--[[ LOCAL FUNCTIONS ]]--

--[[ STATE FUNCTIONS ]]--

function state:init() -- luacheck: no self
  -- dunno
end

function state:enter(_, route, view, report) -- luacheck: no self

  _view = view
  _alert = false

  local ok, animation = pcall(function () return ANIMATIONS[report.type] end)
  if ok then
    _animation_task = animation:script(route, view, report)
  else
    _view.sector:startVFX(report)
    _view.action_hud:sendAlert(
      report.type == 'text_rise' and
      (report.body == route:getControlledActor():getBody())
    )
  end

end

function state:leave() -- luacheck: no self

  Util.destroyAll()

end

function state:update(_) -- luacheck: no self

  if INPUT.wasAnyPressed(0.5) then
    _alert = true
  end

  if not _view.sector:hasPendingVFX() then
    if not _animation_task or _animation_task:done() then
      SWITCHER.pop(_alert)
    end
  end

end

function state:draw() -- luacheck: no self

    Draw.allTables()

end

return state
