
local INPUT = require 'input'
local Util  = require "steaming.util"
local Draw  = require "draw"
local ANIMATIONS = require 'lux.pack' 'gamestates.animations'

local state = {}

--[[ LOCAL VARIABLES ]]--

local _animation_task
local _view
local _alert
local _route
local _report

--[[ LOCAL FUNCTIONS ]]--

--[[ STATE FUNCTIONS ]]--

function state:init()
  -- dunno
end

function state:enter(_, route, view, report)

  _view = view
  _alert = false
  _route = route
  _report = report

  local ok, animation = pcall(function () return ANIMATIONS[report.type] end)
  if ok then
    report.pending = true
    animation:script(route, view, report)
  else 
    _view.sector:startVFX(report)
    _view.action_hud:sendAlert(
      report.type == 'text_rise' and
      (report.body == route:getControlledActor():getBody())
    )
  end

end

function state:leave()

  _report = nil
  Util.destroyAll()

end

function state:update(dt)

  if INPUT.wasAnyPressed(0.5) then
    _alert = true
  end

  if not _view.sector:hasPendingVFX() and not _report.pending then
    SWITCHER.pop(_alert)
  else
    _view.sector:updateVFX(dt)
  end

end

function state:draw()

    Draw.allTables()

end

return state

