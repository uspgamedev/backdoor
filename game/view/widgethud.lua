
local PLACEMENTS = require 'domain.definitions.placements'
local WIDGETVIEW = require 'view.helpers.widget'

local _SCROLL_LIMIT = 5
local _FADE = "_IN_OUT_FADE_"
local _PRIORITIES = {
  [PLACEMENTS.weapon] = 1,
  [PLACEMENTS.offhand] = 2,
  [PLACEMENTS.suit] = 3,
  [PLACEMENTS.tool] = 4,
  [PLACEMENTS.accessory] = 5,
  none = 6
}

local _MG = 20
local _WIDTH, _HEIGHT

local function _initGraphicValues()
  local g = love.graphics
  _WIDTH, _HEIGHT = g.getDimensions()
end

local view = Class({
  __includes = { ELEMENT }
})

function view:init(route)
  ELEMENT.init(self)

  self.route = route
  self.enter = 1
  self.top = 1
  self.widget_list = {}

  _initGraphicValues()
end

function view:fadeIn()
  self:removeTimer(_FADE, MAIN_TIMER)
  self:addTimer(_FADE, MAIN_TIMER, "tween", .25,
                self, { enter = 1 }, "linear"
  )
end

function view:fadeOut()
  self:removeTimer(_FADE, MAIN_TIMER)
  self:addTimer(_FADE, MAIN_TIMER, "tween", .25,
                self, { enter = 0 }, "linear"
  )
end

function view:scrollDown()
  self.top = math.min(self.top + 1, #self.widget_list - _SCROLL_LIMIT)
end

function view:scrollUp()
  self.top = math.max(self.top - 1, 1)
end

function view:isValidActor()
  self.actor = self.route.getControlledActor() or self.actor
  return self.actor
end

function view:getWidgetList(actor)
  local body = actor:getBody()
  local widget_list = {}
  for index, widget in body:eachWidget() do
    widget_list[index] = widget
  end
  table.sort(widget_list, function(a, b)
    local placement_a = PLACEMENTS[a:getWidgetPlacement()] or "none"
    local placement_b = PLACEMENTS[b:getWidgetPlacement()] or "none"
    local ap = _PRIORITIES[placement_a]
    local bp = _PRIORITIES[placement_b]
    return ap < bp
  end)
  self.widget_list = widget_list
  return widget_list
end

function view:draw()
  local g = love.graphics
  local actor = self:isValidActor()
  local widget_list = self:getWidgetList(actor)
  local enter = self.enter
  if not actor or not widget_list then return end

  if enter > 0 then
    local w = WIDGETVIEW.getWidth()
    g.push()
    g.translate(_WIDTH - w - 40, 120)
    for i = self.top, math.min(_SCROLL_LIMIT, #widget_list) do
      if not widget_list[i] then break end
      local widget = widget_list[i]
      local h = WIDGETVIEW.getHeight(widget)
      WIDGETVIEW.draw(widget, 0, 0, enter)
      g.translate(0, _MG + h)
    end
    g.pop()
  end
end

return view

