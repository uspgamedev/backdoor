--DEPENDENCIES--
local RES = require 'resources'
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'
local Queue = require 'lux.common.Queue'


--CLASS VIEW--
local StartMenuView = Class{
  __includes = { ELEMENT }
}

local TITLE_TEXT = "backdoor"
local LH = 1.5
local TILE_W, TILE_H = 80, 80

local SCROLL_THRESHOLD = 4
local _title_font_size = 48
local _menu_font_size = 24
local _menu_font, _title_font
local WIDTH, HEIGHT



local function _initFontValues()
  local g = love.graphics
  _title_font = FONT.get("Title", _title_font_size)
  _title_font:setLineHeight(LH)
  _menu_font = FONT.get("Text", _menu_font_size)
  _menu_font:setLineHeight(LH)
  WIDTH, HEIGHT = g.getDimensions()
end


local function _renderTitle()
  local g = love.graphics
  g.push()
  g.translate(0, HEIGHT/4)
  FONT.set(_title_font)
  g.setColor(COLORS.NEUTRAL)
  g.print(TITLE_TEXT, 0, 0)
  g.pop()
end


local function _renderOptions(q, selection, scrolltop)
  local g = love.graphics
  g.push()
  g.translate(0, HEIGHT/2)
  FONT.set(_menu_font)
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
      g.translate(0, LH*_menu_font_size)
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
  g.translate(4*TILE_W, 0)

  _renderTitle()
  _renderOptions(q, self.selection, self.scrolltop)

  g.pop()
end


return StartMenuView
