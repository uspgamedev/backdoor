--MODULE FOR DRAWING STUFF--

local CAM = require 'common.camera'
local tween = require 'helpers.tween'
local first_time = false
local Util  = require "steaming.util"

local _GAMEFRAMEWIDTH = 960

local _fade

local draw = {}

----------------------
--BASIC DRAW FUNCTIONS
----------------------

--Update every drawable object
function draw.update(dt)
  Util.updateSubtype(dt, 'frontend-hud')
  for _,layer in pairs(DRAW_TABLE) do
    for o in pairs(layer) do
      if not o.death and not o.invisible and o.update then
        o:update(dt)
      end
    end
  end
end

--Draws every drawable object from all tables
function draw.allTables()

  DrawTable(DRAW_TABLE.BG)

  CAM:attach(nil, nil, _GAMEFRAMEWIDTH) --Start tracking camera

  DrawTable(DRAW_TABLE.L1)

  DrawTable(DRAW_TABLE.L2)

  CAM:detach() --Stop tracking camera

  DrawTable(DRAW_TABLE.HUD_BG)

  DrawTable(DRAW_TABLE.HUD_FX)

  DrawTable(DRAW_TABLE.HUD)

  if DEBUG and first_time then
    _fade = tween.start(0, 50, 5)
    first_time = false
  elseif not DEBUG and not first_time then
    _fade = tween.start(50, 0, 5)
    first_time = true
  end
  local g = love.graphics
  g.setColor(1, 1, 1, _fade()/255)
  g.rectangle('fill', 0, 0, g.getDimensions())

  DrawTable(DRAW_TABLE.GUI)

  SWITCHER.handleChangedState()
end

--Draw all the elements in a table
function DrawTable(t)

  for o in pairs(t) do
    if not o.invisible then
      o:draw() --Call the object respective draw function
    end
  end

end

--Return functions
return draw
