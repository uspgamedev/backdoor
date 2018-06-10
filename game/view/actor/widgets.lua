
local RES        = require 'resources'
local PLACEMENTS = require 'domain.definitions.placements'
local COLORS     = require 'domain.definitions.colors'
local FONT       = require 'view.helpers.font'

local _font
local _MG = 24
local _PD = 4
local _SQRSIZE = 36

local _widgetgetter
local _widgetstring = {
  "PLACEMENTS",
  "TRAITS",
  "CONDITIONS",
}

local function _getPlacements(body)
  local placements, n = {}, 0
  for _,slot in ipairs(PLACEMENTS) do
    local placement = body:getEquipmentAt(slot)
    n = n + 1
    placements[n] = placement
  end
  return placements
end

local function _getTraits(body)
  local traits, n = {}, 0
  for i,widget in body:eachWidget() do
    if not widget:getWidgetPlacement() and widget:isWidgetPermanent() then
      n = n + 1
      traits[n] = widget
    end
  end
  return traits
end

local function _getConditions(body)
  local conditions, n = {}, 0
  for i,widget in body:eachWidget() do
    if not widget:getWidgetPlacement() and not widget:isWidgetPermanent() then
      n = n + 1
      conditions[n] = widget
    end
  end
  return conditions
end


local WIDGETS = {}

function WIDGETS.init()
  _font = FONT.get("Text", 20)
  _widgetgetter = {
    _getPlacements,
    _getTraits,
    _getConditions
  }
end

function WIDGETS.draw(g, actor, wtype)
  local widgets = _widgetgetter[wtype](actor:getBody())

  -- set position
  g.translate(0, _MG*2)
  g.setColor(COLORS.NEUTRAL)
  g.print(_widgetstring[wtype], 0, 0)
  g.translate(0, _font:getHeight())

  for i = 1, 5 do
    -- draw the first 5 widgets
    g.push()
    g.translate((i - 1) * (_SQRSIZE + _PD), 0)
    g.setColor(COLORS.EMPTY)
    g.rectangle("fill", 0, 0, _SQRSIZE, _SQRSIZE)
    local widget = widgets[i]
    if widget then
      local icon = RES.loadTexture(widget:getIconTexture() or 'icon-none')
      local iw, ih = icon:getDimensions()
      icon:setFilter('linear', 'linear')
      g.setColor(COLORS[widget:getRelatedAttr()])
      g.rectangle("fill", 0, 0, _SQRSIZE, _SQRSIZE)
      g.setColor(COLORS.BLACK)
      g.draw(icon, 0, 0, 0, _SQRSIZE/iw, _SQRSIZE/ih)
    elseif wtype == 1 then
      g.setColor(COLORS.BLACK)
      g.printf(PLACEMENTS[PLACEMENTS[i]]:lower(), 0, 0, _SQRSIZE, "center")
    end
    g.pop()
  end

  if widgets[6] then
    -- if there are more than 5 widgets
    g.push()
    g.translate(5 * (_SQRSIZE + _PD), 0)
    g.setColor(COLORS.DARK)
    g.rectangle("fill", 0, 0, _SQRSIZE, _SQRSIZE)
    g.setColor(COLORS.NEUTRAL)
    g.printf("...", 0, 0, _SQRSIZE, "center")
    g.pop()
  end
end

return WIDGETS

