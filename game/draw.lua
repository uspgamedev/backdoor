--MODULE FOR DRAWING STUFF--

local tween = require 'helpers.tween'
local first_time = false

local fade = 1

local draw = {}

----------------------
--BASIC DRAW FUNCTIONS
----------------------

--Draws every drawable object from all tables
function draw.allTables()

    DrawTable(DRAW_TABLE.BG)

    CAM:attach() --Start tracking camera

    DrawTable(DRAW_TABLE.L1)

    DrawTable(DRAW_TABLE.L2)

    CAM:detach() --Stop tracking camera

    DrawTable(DRAW_TABLE.HUDl)

    DrawTable(DRAW_TABLE.HUD)

    if DEBUG and first_time then
      fade = tween.start(0, 50, 5)
      first_time = false
    elseif not DEBUG and not first_time then
      fade = tween.start(50, 0, 5)
      first_time = true
    end
    local g = love.graphics
    g.setColor(255, 255, 255, fade())
    g.rectangle('fill', 0, 0, 1280, 720)

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
