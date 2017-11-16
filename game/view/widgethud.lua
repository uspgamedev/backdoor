
local PLACEMENTS = require 'domain.definitions'
local WIDGETVIEW = require 'view.helpers.widget'

local _SCROLL_LIMIT = 8
local _FADE = "_IN_OUT_FADE_"
local _PRIORITIES = {
  [PLACEMENTS.weapon] = 1,
  [PLACEMENTS.offhand] = 2,
  [PLACEMENTS.suit] = 3,
  [PLACEMENTS.tool] = 4,
  [PLACEMENTS.accessory] = 5,
  none = 6
}

local _MG = 24
local _WIDTH, _HEIGHT

local function _initGraphicValues()
  local g = love.graphics
  _WIDTH, _HEIGHT = g.getDimensions()
end

local view = Class({
  __include = { ELEMENT }
})

function view:init(route)
  self.route = route
  self.enter = 0
  self.top = 1
  self.widget_list
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
  self.actor = route.getControlledActor() or self.actor
  return self.actor
end

function view:getWidgetList(actor)
  local body = actor:getBody()
  local widget_list = {}
  for index, widget in body:eachWidget() do
    widget_list[index] = widget
  end
  table.sort(widget_list, function(a, b)
    return _PRIORITIES[a:getWidgetPlacement() or "none"]
           < _PRIORITIES[b:getWidgetPlacement() or "none"]
  end)
  self.widget_list = widget_list
  return widget_list
end

function view:draw()
  local g = love.graphics
  local actor = self:isValidActor()
  local widget_list = self:getWidgetList(actor)
  if not actor or not widget_list then return end

  if self.enter > 1 then
    local w, h = WIDGETVIEW.getDimensions()
    g.push()
    g.translate(_WIDTH - w - 2*_MG, 160)
    for i = self.top, _SCROLL_LIMIT do
      if not widget_list[self.top] then break end
      local widget = widget_list[self.top]
      WIDGETVIEW.draw(widget, 0, (i-self.top)*h, enter)
    end
    g.pop()
  end
end

