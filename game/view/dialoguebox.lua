
local Class    = require "steaming.extra_libs.hump.class"
local VIEWDEFS = require 'view.definitions'
local ELEMENT  = require "steaming.classes.primitives.element"
local COLORS   = require 'domain.definitions.colors'
local FONT     = require 'view.helpers.font'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _FX_MAGNITUDE = 6
local _FX_SPEED = 2.5
local _font = FONT.get('Text', 20)

--Box attributes
local _X_MARGIN = _TILE_W/6
local _Y_OFFSET = -_TILE_H/3
local _MAX_WIDTH = 2*_TILE_W

--Text attributes
local _TEXT_MARGIN = 5
local _TEXT_START_UP_TIME = .15

--Time a character must stay active before next one appears
local _CHAR_SPEED = {
  slow      = .5,
  medium    = .15,
  regular   = .08,
  fast      = .04,
  ultrafast = .02
}

--Color a character can have
local _CHAR_COLOR = {
  regular = "NEUTRAL",
  red     = "NOTIFICATION",
  blue    = "VALID",
  green   = "SUCCESS",
}

--Wave style consts
local _WAVE_MAGNITUDE = 2
local _WAVE_SPEED = 5
local _WAVE_REGULATOR = 10

--Forward declaration for local functions
local getTag

--[[
HOW TEXT AND TAGS WORK

You can create a stylized text using tags. Tags follow the pattern
[type_of_effect=value]

Valid values for type and value are as follows:
type of effect - what it does
  value1 - what it does
  value2 - what it does
  valueN - what it does

speed - Set current speed the text should appear
  slow      - slowest speed
  medium    - slower than regular speed
  regular   - regular speed
  fast      - fast speed
  ultrafast - fastest speed

style - Set current style for the text
  none  - remove any style
  wave  - wave-like text
  shake - characters will shake frenetically

color - Set current color to draw text
  regular - default color (white)
  red     - red color
  blue    - blue color
  green   - green color

]]

-- Class

local DialogueBox = Class{
  __includes = { ELEMENT }
}

--[[ PUBLIC METHODS ]]--

function DialogueBox:init(body, i, j, side)
  ELEMENT.init(self)

  --Timer to display characters gradually
  self.char_timer = 0

  self.text = self:parseText(body:getDialogue())

  --Dialogue box position attributes
  self.i = i
  self.j = j
  self.side = side

end

function DialogueBox:draw()
  local g = love.graphics
  local x, y = self:getPosition()
  local w, h = self:getSize()

  g.push()
  g.translate(x, y)

  --Draw bg
  g.setColor(COLORS.HUD_BG)
  g.rectangle("fill", 0, 0, w, h)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(3)
  g.rectangle("line", 0, 0, w, h)

  --Draw text
  _font:set()
  self:updateText(love.timer.getDelta())
  local t = _TEXT_START_UP_TIME
  if t < self.char_timer then
    for i, c in ipairs(self.text) do
      local ox, oy = 0, 0
      if c.style == "wave" then
        oy = math.sin((love.timer.getTime() + i/_WAVE_REGULATOR) * _WAVE_SPEED) * _WAVE_MAGNITUDE
      end
      g.setColor(COLORS[c.color])
      g.print(c.char, c.x + ox, c.y + oy)
      t = t + c.time
      if t > self.char_timer then break end
    end
  end

  g.pop()
end

function DialogueBox:setSide(side)
  self.side = side
end

function DialogueBox:getPosition()
  local x, y
  local w, h = self:getSize()

  if self.side == "right" then
    x = (self.j+1)*_TILE_W + _X_MARGIN
  elseif self.side == "left" then
    x = self.j*_TILE_W -_X_MARGIN - w
  else
    error("not a valid side for dialogue box")
  end

  local fx_offset = math.sin(love.timer.getTime() * _FX_SPEED) * _FX_MAGNITUDE
  y = (self.i+.5)*_TILE_H - h/2 + _Y_OFFSET + fx_offset

  return math.floor(x + .5), math.floor(y + .5)
end

function DialogueBox:getSize()
  local max_x = 0
  for _, c in ipairs(self.text) do
    if max_x < c.x + _font:getWidth(c.char) then
      max_x = c.x + _font:getWidth(c.char)
    end
  end
  local w = math.min(max_x + _TEXT_MARGIN, _MAX_WIDTH)
  local h = self.text[#self.text].y + _font:getHeight()
  return w, h
end

function DialogueBox:updateText(dt)
  self.char_timer = self.char_timer + dt
end

function DialogueBox:parseText(text)
  local parsed = {}
  local x = _TEXT_MARGIN
  local y = 0
  local i = 1

  --Default value
  local time = _CHAR_SPEED.regular
  local color = _CHAR_COLOR.regular
  local style = "none"

  while i <= text:len() do
    local char = text:sub(i,i)

    --Special tag
    if char == "[" then
      local effect_type, effect_value

      --Get effect
      text, effect_type, effect_value = getTag(text, i)

      --Apply effect
      local err = false
      if effect_type == "speed" then
        if _CHAR_SPEED[effect_value] then
          time = _CHAR_SPEED[effect_value]
        else
          err = true
        end
      elseif effect_type == "color" then
        if _CHAR_COLOR[effect_value] then
          color = _CHAR_COLOR[effect_value]
        else
          err = true
        end
      elseif effect_type == "style" then
        if effect_value == "none" or
           effect_value == "wave" or
           effect_value == "shake" then
             style = effect_value
        else
          err = true
        end
      else
        err = true
      end

      --Check for errors
      if err then
        error([[Effect invalid!
             Type = "]]..effect_type..[["
             Value = "]]..effect_value..[["]])
      end

    --Common character
    else

      local w = _font:getWidth(char)
      parsed[i] = {
        char = char,
        x = x,
        y = y,
        time = time,
        color = color,
        style = style
      }
      x = x + w

      --Wrap words
      if x > _MAX_WIDTH - 2*_TEXT_MARGIN then
        y = y + _font:getHeight()
        x = _TEXT_MARGIN
        --Find start of current word
        local j = i
        while j >= 1 do
          if parsed[j].char == " " then break end
          j = j - 1
        end
        if j == 0 then error("Word is too damn big") end
        --Fix position of every character
        for k = j+1, i do
          local w = _font:getWidth(parsed[k].char)
          parsed[k].x = x
          parsed[k].y = y
          x = x + w
        end
      end

      --Update iterator
      i = i + 1
    end
  end

  return parsed
end

--Local functions

--Gets a tag effect that starts from given position, and removes that tag from the text
--A tag must follow the pattern [type_of_effect=value]
function getTag(text, tag_start_pos)
  if text:sub(tag_start_pos,tag_start_pos) ~= "[" then
    error("isn't a valid tag position")
  end

  --Find tag end position
  local i = tag_start_pos + 1
  while i <= text:len() and text:sub(i,i) ~= ']' do
    i = i + 1
  end
  if i > text:len() then
    error("Reached end of text and tag wasn't closed")
  end

  --Get complete effect from tag
  local tag_end_pos = i
  local effect = text:sub(tag_start_pos + 1, tag_end_pos - 1)

  --Extract type and value from effect
  local type, value = effect:match("(%w+)=(%w+)")
  if not type or not value then
    error("tag didn't match [type=value] pattern")
  end

  --Remove tag from text
  text = text:sub(0, tag_start_pos - 1) .. text:sub(tag_end_pos + 1, -1)


  return text, type, value
end

return DialogueBox
