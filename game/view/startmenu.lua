--DEPENDENCIES--
local RES = require 'resources'
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'
local Queue = require 'lux.common.Queue'


--CLASS VIEW--
local StartMenuView = Class{
  __includes = { ELEMENT }
}

local _TITLE_TEXT = "backdoor"
local _LH = 1.5
local _TILE_W, _TILE_H = 80, 80

local _SCROLL_THRESHOLD = 4
local _TITLE_FONT_SIZE = 48
local _MENU_FONT_SIZE = 24


local _menu_font, _title_font
local _width, _height

local function _initFontValues()
  local g = love.graphics
  _title_font = _title_font or FONT.get("Title", _TITLE_FONT_SIZE)
  _title_font:setLineHeight(_LH)
  _menu_font = _menu_font or FONT.get("Text", _MENU_FONT_SIZE)
  _menu_font:setLineHeight(_LH)
  _width, _height = g.getDimensions()
end


local function _renderTitle()
  local g = love.graphics
  g.push()
  g.translate(0, _height/4)
  _title_font:set()
  g.setColor(COLORS.NEUTRAL)
  g.print(_TITLE_TEXT, 0, 0)
  g.pop()
end


local function _renderOptions(q, selection, scrolltop)
  local g = love.graphics
  g.push()
  g.translate(0, _height/2)
  _menu_font:set()
  local count = 0
  while not q.isEmpty() do
    local item_text = q.pop()
    local color = COLORS.BACKGROUND
    count = count + 1
    if count >= scrolltop and count < scrolltop + _SCROLL_THRESHOLD then
      if selection == count then
        color = COLORS.NEUTRAL
      end
      g.setColor(color)
      g.print(item_text, 0, 0)
      g.translate(0, _menu_font:getHeight())
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
  if n >= self.scrolltop + _SCROLL_THRESHOLD then
    self.scrolltop = n - _SCROLL_THRESHOLD + 1
  end
  self.selection = n
end


function StartMenuView:draw()

  local g = love.graphics
  local q = self.queue

  g.push()
  g.setBackgroundColor(0, 0, 0)
  g.translate(4*_TILE_W, 0)

  _renderTitle()
  _renderOptions(q, self.selection, self.scrolltop)

  g.pop()
end


return StartMenuView
