
local RES = require 'resources'
local COLORS = require 'domain.definitions.colors'
local SHADERS = require 'view.shaders'

local PANEL = {}

local _panel

function PANEL.init(width, height, mg)
  local g = love.graphics
  local points = {
    {width+mg, 0},
    {0, 0},
    {0, mg+height/2},
    {mg, 2*mg+height/2},
    {mg, height},
    {width+mg, height},
  }
  local contour = {
    mg/2, -2*mg,
    mg/2, mg+height/2,
    3/2*mg, 2*mg+height/2,
    3/2*mg, height+2*mg,
  }
  for _,point in ipairs(points) do
    point[3] = point[1]/width
    point[4] = point[2]/height
  end
  local mesh = g.newMesh(points, 'fan', 'static')
  local canvas = g.newCanvas(width+3*mg, height+2*mg)
  local theme = RES.loadTexture("panel-theme")
  theme:setWrap('repeat')
  mesh:setTexture(theme)
  canvas:setFilter('linear', 'linear')
  canvas:renderTo(function()
    g.push()
    g.setBackgroundColor(COLORS.VOID)
    g.clear()
    g.origin()
    g.translate(mg, mg)
    g.setColor(1, 1, 1)
    g.draw(mesh, 0, 0)
    g.pop()
  end)
  local dropshadow = g.newImage(canvas:newImageData())
  canvas:renderTo(function ()
    g.push()
    g.setBackgroundColor(COLORS.VOID)
    g.clear()
    g.origin()
    g.translate(mg, mg)
    SHADERS.gaussian:send('tex_size', { canvas:getDimensions() })
    SHADERS.gaussian:send('range', 12)
    g.setShader(SHADERS.gaussian)
    g.setColor(0, 0, 0, 1)
    g.draw(dropshadow, -1.5*mg, -mg)
    g.setShader()
    g.setColor(1, 1, 1)
    g.draw(mesh, 0, 0)
    g.setColor(COLORS.NEUTRAL)
    g.setLineWidth(2)
    g.line(contour)
    g.translate(8, 0)
    g.line(contour)
    g.pop()
  end)
  _panel = canvas
end

function PANEL.draw(g, ...)
  g.draw(_panel, ...)
end

return PANEL

