--CHARACTER BUILDER VIEW--
local DB = require 'database'
local RES = require 'resources'
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'
local Class = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

--CONSTANTS--
local _CONTEXTS = {
  "Species",
  "Background",
  "Are you sure?",
}

local _PLAYER_FIELDS = {
  'species',
  'background',
  'confirm',
}

local _SPECS = {
  species = 'body',
  background = 'actor',
}

local _FADE_TIME = .4
local _PD = 16
local _LH = 1.5
local _WIDTH
local _HEIGHT


--LOCALS--
local _header_font
local _content_font
local _info_font
local _menu_values


local sin = math.sin
local pi  = math.pi
local delta = love.timer.getDelta

--MODULE--
local View = Class{
  __includes = { ELEMENT }
}


--LOCAL FUNCTIONS--

local function _initValues()
  local playables = DB.loadSetting("playable")
  local g = love.graphics
  _menu_values = {
    species     = playables.species,
    background  = playables.background,
    confirm     = {true, false},
  }
  _WIDTH, _HEIGHT = g.getDimensions()
  _header_font  = FONT.get("Text", 32)
  _content_font = FONT.get("Text", 24)
  _info_font = FONT.get("Text", 28)
end

local function _getSpec(field, specname)
  return DB.loadSpec(_SPECS[field], specname)
end

function View:init()
  ELEMENT.init(self)

  self.enter = 0
  self.context = 1
  self.selection = 1
  self.arrow = 0
  self.leave = false
  self.sprite = false

  _initValues()
end

function View:open(player_info)
  self.player_info = player_info
  self:removeTimer('charabuild_fade', MAIN_TIMER)
  self:addTimer('charabuild_fade', MAIN_TIMER, "tween", _FADE_TIME,
                self, { enter = 1 }, "linear"
  )
end

function View:close(after)
  self:removeTimer('charabuild_fade', MAIN_TIMER)
  self:addTimer('charabuild_fade', MAIN_TIMER, "tween", _FADE_TIME,
                self, { enter = 0 }, "linear", after
  )
end

function View:reset()
  self.context = 1
  self.selection = 1
  self.sprite = false
end

function View:selectPrev()
  local context = _PLAYER_FIELDS[self.context]
  local menu_size = #_menu_values[context]
  self.selection = (self.selection + menu_size - 2) % menu_size + 1
  if self.context == 1 then self.sprite = false end
end

function View:selectNext()
  local context = _PLAYER_FIELDS[self.context]
  local menu_size = #_menu_values[context]
  self.selection = self.selection % menu_size + 1
  if self.context == 1 then self.sprite = false end
end

function View:confirm()
  local context = _PLAYER_FIELDS[self.context]
  self.player_info[context] = _menu_values[context][self.selection]
  self.context = self.context + 1
  self.selection = 1
end

function View:cancel()
  local context = _PLAYER_FIELDS[self.context]
  self.player_info[context] = false
  self.context = self.context - 1
  if self.context < 1 then
    self.leave = true
    self.context = 1
  end
  self.selection = 1
end

function View:getContext()
  return self.context
end

function View:draw()
  local g = love.graphics
  local enter = self.enter
  local player_info = self.player_info
  local context = _PLAYER_FIELDS[self.context]
  local selection = self.selection

  g.setBackgroundColor(0, 0, 0)
  g.setColor(1, 1, 1, enter)

  self:drawSaved(g, player_info)
  self:drawContext(g)
  self:drawSpecies(g, player_info)
  self:drawBackgroundInfo(g, player_info)
  if self.context > #_CONTEXTS then return end
  self:drawSelection(g, context, selection)

end

function View:drawSpecies(g, player_info)
  g.push()
  g.translate(_WIDTH/2, _HEIGHT/2)

  --Draw species sprite
  local species = player_info.species or _menu_values.species[self.selection]
  if not self.sprite and species then
    local appearance_specname = _getSpec('species', species)['appearance']
    local appearance = DB.loadSpec('appearance', appearance_specname)
    self.sprite = RES.loadSprite(appearance.idle)
  end
  if self.sprite then self.sprite:draw(-40, 0) end

  g.pop()
  g.push()
  --Draw species base HP
  g.translate(_WIDTH/9, _HEIGHT/3)
  _info_font:set()
  local text = {COLORS.NEUTRAL, "BASE HP: ", COLORS.NOTIFICATION, _getSpec('species', species)['basehp']}
  g.print(text, 0, 0)
  g.pop()
end

function View:drawBackgroundInfo(g, player_info)
  if self.context > 1 then
    local background = player_info.background or _menu_values.background[self.selection]
    local bg_spec = _getSpec('background', background)
    g.push()
    _info_font:set()
    g.translate(_WIDTH/9, _HEIGHT/3 + 40)

    --Aptitudes
    g.print("APTITUDES:", 0, 0)
    g.translate(0, 40)
    g.push()
    g.print({COLORS.COR, "COR: ", COLORS.COR, bg_spec.cor}, 0, 0)
    g.translate(100, 0)
    g.print({COLORS.ARC, "ARC: ", COLORS.ARC, bg_spec.arc}, 0, 0)
    g.translate(100, 0)
    g.print({COLORS.ANI, "ANI: ", COLORS.ANI, bg_spec.ani}, 0, 0)
    g.pop()

    --Buffer
    g.translate(0, 60)
    g.setColor(COLORS.NEUTRAL)
    g.print("INITIAL BUFFER:", 0, 0)
    g.translate(0, 60)
    for 
    g.pop()
  end
end

function View:drawSelection(g, context, selection)
  g.push()
  g.translate(_WIDTH/2, _HEIGHT/2 + _header_font:getHeight())
  g.setColor(1, 1, 1, enter)
  local text = _menu_values[context][selection]
  local spec
  if type(text):match('boolean') then text = text and "Yes" or "No"
  else
    spec = _getSpec(context, text)
    text = spec['name']
  end
  g.printf(text, -256, 0, 512, "center")

  local w = _header_font:getWidth(text) / 2 + _PD * 2
  self.arrow = (self.arrow + 2 * pi * delta()) % pi

  g.push()
  g.translate(-sin(self.arrow)*_PD/2, _PD*1.8)
  g.polygon("fill", -w, 0, -w+_PD, -_PD/2, -w+_PD,  _PD/2)
  g.pop()

  g.push()
  g.translate(sin(self.arrow)*_PD/2, _PD*1.8)
  g.polygon("fill",  w, 0,  w-_PD,  _PD/2,  w-_PD, -_PD/2)
  g.pop()

  g.pop()

  if spec then
    g.push()
    g.translate(2*_WIDTH/3-40,
                _HEIGHT/2 + 40)
    local specname = _menu_values[context][selection]
    local name = _getSpec(context, specname)['name']
    local desc = _getSpec(context, specname)['description']
    _header_font:set()
    _header_font:setLineHeight(1)
    g.printf(name, 0, -_header_font:getHeight(), 400, "left")
    _content_font:set()
    _content_font:setLineHeight(1)
    g.printf(desc:gsub("([^\n])\n([^\n])", "%1 %2"), 0, 0, 400, "left")
    g.pop()
  end

end

function View:drawContext(g)
  -- draw current options in context
  _header_font:set()
  g.push()
  g.translate(_WIDTH/2, _HEIGHT/2 - 160)
  g.printf(_CONTEXTS[self.context] or "ROUTE START!", -256, 0, 512, "center")
  g.pop()
end

function View:drawSaved(g, player_info)
  -- draw current state
  _header_font:setLineHeight(1)
  _header_font:set()
  g.push()
  g.translate(_WIDTH/9, _HEIGHT/3 - 2*_header_font:getHeight())
  g.setColor(0x38/255, 0xe4/255, 1, self.enter)
  for i = 1, self.context - 1 do
    local field = _PLAYER_FIELDS[i]
    local specname = player_info[field]
    if specname == true or specname == false then break end

    g.print(_getSpec(field, specname)['name'], 0, 0)
    g.translate(0, _header_font:getHeight() - 16)
  end
  g.setColor(1, 1, 1, self.enter)
  g.pop()
end

return View
