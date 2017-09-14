--DEPENDENCIES--
local DB = require 'database'
local COLORS = require 'domain.definitions.colors'
local Queue = require 'lux.common.Queue'


--CLASS VIEW--
local StartMenuView = Class{
  __includes = { ELEMENT }
}


local TITLE_FONT_PATH = DB.loadFontPath("Anton")
local MENU_FONT_PATH = DB.loadFontPath("Saira")
local TITLE_TEXT = "backdoor"
local TITLE_FONT_SIZE = 48
local MENU_FONT_SIZE = 24
local LH = 1.5
local TILE_W, TILE_H = 80, 80

local SCROLL_THRESHOLD = 4

local MENU_FONT, TITLE_FONT
local WIDTH, HEIGHT


local function _initFontValues()
  local g = love.graphics
  TITLE_FONT = g.newFont(TITLE_FONT_PATH, TITLE_FONT_SIZE)
  TITLE_FONT:setLineHeight(LH)
  MENU_FONT = g.newFont(MENU_FONT_PATH, MENU_FONT_SIZE)
  MENU_FONT:setLineHeight(LH)
  WIDTH, HEIGHT = g.getDimensions()
end


local function _renderTitle()
  local g = love.graphics
  g.push()
  g.translate(0, HEIGHT/4)
  g.setFont(TITLE_FONT)
  g.setColor(COLORS.NEUTRAL)
  g.print(TITLE_TEXT, 0, 0)
  g.pop()
end


local function _renderOptions(q, selection, scrolltop)
  local g = love.graphics
  g.push()
  g.translate(0, HEIGHT/2)
  g.setFont(MENU_FONT)
  local count = 0
  while not q.isEmpty() do
    local item_text = q.pop()
    local color = COLORS.BACKGROUND
    count = count + 1
    if count >= scrolltop and count < scrolltop + SCROLL_THRESHOLD then
      if selection == count then
        color = COLORS.NEUTRAL
      end
      g.setColor(color)
      g.print(item_text, 0, 0)
      g.translate(0, LH*MENU_FONT_SIZE)
    end
  end
  g.pop()
end


function StartMenuView:init()

  ELEMENT.init(self)

  self.queue = Queue(128)
  self.title = "backdoor"
  self.selection = 1
  self.scrolltop = 1

  _initFontValues()

end


function StartMenuView:setItem(item_text)
  self.queue.push(item_text)
end


function StartMenuView:setSelection(n)
  if n < self.scrolltop then
    self.scrolltop = n
  end
  if n >= self.scrolltop + SCROLL_THRESHOLD then
    self.scrolltop = n - SCROLL_THRESHOLD + 1
  end
  self.selection = n
end


function StartMenuView:draw()

  local g = love.graphics
  local q = self.queue

  g.push()
  g.setBackgroundColor(0, 0, 0)
  g.translate(2*TILE_W, 0)

  _renderTitle()
  _renderOptions(q, self.selection, self.scrolltop)

  g.pop()
  self.queue.popAll()
end


return StartMenuView

