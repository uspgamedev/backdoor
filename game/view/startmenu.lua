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

local _SCROLL_THRESHOLD = 6
local _TITLE_FONT_SIZE = 48
local _MENU_FONT_SIZE = 24
local _FADE_TIME = .5

local _LOGO_BG_PARTS = 11
local _LOGO_BG = {}
local _LOGO_TEXT

local _menu_font, _title_font
local _width, _height

local function _initFontValues()
  local g = love.graphics
  _title_font = _title_font or FONT.get("Title", _TITLE_FONT_SIZE)
  _menu_font = _menu_font or FONT.get("Text", _MENU_FONT_SIZE)
  _width, _height = g.getDimensions()
end

local function _initLogo()
  for i = 1, _LOGO_BG_PARTS do
    _LOGO_BG[i] = RES.loadTexture('logo-bg'..i)
  end
  _LOGO_TEXT = RES.loadTexture('logo-text')
end

local function _renderTitle(g)
  g.push()
  g.translate(-_width/8, -_height/8)
  g.setColor(COLORS.NEUTRAL)
  for i = 1, _LOGO_BG_PARTS do
    g.draw(_LOGO_BG[i],0,0)
  end
  g.draw(_LOGO_TEXT,-50,120)
  g.pop()
end


local function _renderOptions(g, q, selection, scrolltop)
  g.push()
  g.translate(320, 450)
  _menu_font:set()
  _menu_font:setLineHeight(_LH)
  local count = 0
  while not q.isEmpty() do
    local item_text = q.pop()
    local text_color = COLORS.BACKGROUND
    count = count + 1
    if count >= scrolltop and count < scrolltop + _SCROLL_THRESHOLD then
      if selection == count then
        text_color = COLORS.NEUTRAL
      end
      g.setColor(text_color)
      g.print(item_text, -_menu_font:getWidth(item_text)/2, 0)
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

  _initLogo()

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

  _renderTitle(g)
  _renderOptions(g, q, self.selection, self.scrolltop)

  g.pop()

end


return StartMenuView
