--CHARACTER BUILDER VIEW--
local Queue = require 'lux.common.Queue'
local COLORS = require 'domain.definitions.colors'


--CONSTANTS--
local PD = 16
local LH = 1.5
local FONT_SIZE = 24
local WIDTH
local HEIGHT
local FONT


--MODULE--
local CharaBuildView = Class{
  __includes = { ELEMENT }
}


--LOCAL FUNCTIONS--
local function _initGraphicValues()
  local g = love.graphics
  WIDTH, HEIGHT = g.getDimensions()
  FONT = g.newFont(FONT_SIZE)
  FONT:setLineHeight(LH)
end

local function _renderSaved(g, saved)
  g.push()
  for _,data in ipairs(saved) do
    local context, name = unpack(data)
    g.push()
    g.translate(WIDTH/2 + 160, 0)
    g.printf(("%s: %s"):format(context, name), 0, 0, WIDTH/4, "left")
    g.pop()
    g.translate(0, FONT_SIZE*LH)
  end
  g.pop()
end

local function _renderOptions(g, sel, width, render_queue)
  local w = width + 2*PD
  local h = FONT:getHeight()/2
  local count = 0
  while not render_queue.isEmpty() do
    local name, data = unpack(render_queue.pop())
    count = count + 1
    if count == sel then
      g.translate(WIDTH/2 - w/2, 0)
      g.polygon("fill", {0, h-PD/2, 0-PD/2, h, 0, h+PD/2})
      g.polygon("fill", {w, h-PD/2, w+PD/2, h, w, h+PD/2})
      g.printf(name, 0, 0, w, "center")
    end
  end
end


--VIEW METHODS--
function CharaBuildView:init()

  ELEMENT.init(self)

  self.selection = 1
  self.context = false
  self.render_queue = Queue(256)
  self.saved = {}
  self.width = 0

  _initGraphicValues()

end

function CharaBuildView:save(context_name, name)
  table.insert(self.saved, {context_name, name})
end

function CharaBuildView:flush()
  for k,v in ipairs(self.saved) do self.saved[k] = nil end
  self.render_queue.popAll()
  self.context = false
end

function CharaBuildView:setContext(context_name)
  self.context = context_name
end

function CharaBuildView:setItem(name, data)
  self.render_queue.push {name, data}
  self.width = math.max(self.width, FONT:getWidth(name))
end

function CharaBuildView:select(n)
  self.selection = n
end

function CharaBuildView:draw()
  if not self.context then return end
  local g = love.graphics
  local render_queue = self.render_queue

  g.push()

  -- reset rendering modifiers
  g.setFont(FONT)
  g.setColor(COLORS.NEUTRAL)
  g.translate(0, HEIGHT/2)

  -- saved data
  _renderSaved(g, self.saved)

  -- context name
  g.translate(0, 160)
  g.printf(("%s"):format(self.context), 0, 0, WIDTH, "center")
  g.translate(0, FONT_SIZE*2)

  -- options
  _renderOptions(g, self.selection, self.width, render_queue)

  g.pop()

  -- reset width
  self.width = 0
end

return CharaBuildView


