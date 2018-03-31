
local PLACEMENTS = require 'domain.definitions.placements'
local WIDGETVIEW = require 'view.helpers.widget'

local _SCROLL_LIMIT = 5
local _FADE = "_IN_OUT_FADE_"
local _MOVE = "_MOVE_SCROLL_"
local _PRIORITIES = {
  [PLACEMENTS.weapon] = 1,
  [PLACEMENTS.offhand] = 2,
  [PLACEMENTS.suit] = 3,
  [PLACEMENTS.tool] = 4,
  [PLACEMENTS.accessory] = 5,
  none = 6
}

local _MG = 10
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
  self.focus = 0
  self.top = 0
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
  if #self.widget_list < _SCROLL_LIMIT then return end
  local max_top = #self.widget_list - _SCROLL_LIMIT + 1
  self.focus = math.min(self.focus+1, max_top)
  self:updateScroll()
end

function view:scrollUp()
  self.focus = math.max(self.focus-1, 0)
  self:updateScroll()
end

function view:updateScroll()
  self:removeTimer(_MOVE, MAIN_TIMER)
  self:addTimer(_MOVE, MAIN_TIMER, "tween", .25,
                self, { top = self.focus },
                "out-back"
  )
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
  if #self.widget_list ~= #widget_list
     and #widget_list < _SCROLL_LIMIT then
    self.focus = 0
    self:updateScroll()
  end
  self.widget_list = widget_list
  return widget_list
end

function view:draw()
  local g = love.graphics

  local actor = self:isValidActor()
  if not actor then return end

  local widget_list = self:getWidgetList(actor)
  if not widget_list then return end

  local enter = self.enter

  if enter > 0 then
    local w = WIDGETVIEW.getWidth()
    local h = WIDGETVIEW.getHeight() + _MG
    g.push()
    g.translate(_WIDTH - w - 40, 120 - h * self.top)
    for i, widget in ipairs(widget_list) do
      WIDGETVIEW.draw(widget, 0, 0, enter)
      g.translate(0, _MG + h)
    end
    g.pop()
  end
end

return view

