
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

--Forward declaration for local functions
local getTag

--[[
HOW TEXT AND TAGS WORK

You can create a stylized text using tags. Tags follow the pattern
[type_of_effect=value]

Valid values for type and value are as follows:
Type of effect - what it does
  value1 - what it does
  value2 - what it does
  valueN - what it does

speed - Set current speed the text should appear
  fastest - fastest speed
  fast    - fast speed
  regular - regular speed
  medium  - slower than regular speed
  slow    - slowest speed

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

  --Box attributes
  self.x_margin = _TILE_W/6
  self.y_offset = -_TILE_H/3
  self.max_width = 2*_TILE_W

  --Text attributes
  self.text_margin = 5
  --time
  self.regular_char_time = .08 --Time to appear a regular char
  self.medium_char_time = .15 --Time to appear a slow char
  self.slow_char_time = .5 --Time to appear a slow char
  self.fast_char_time = .04 --Time to appear a fast char
  self.fastest_char_time = .02 --Time to appear a fast char
  self.text_start_up_time = .15
  self.char_timer = 0
  --color
  self.regular_char_color = "NEUTRAL"
  self.red_char_color = "NOTIFICATION"
  self.blue_char_color = "VALID"
  self.green_char_color = "SUCCESS"

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
  local t = self.text_start_up_time
  if t < self.char_timer then
    for i, c in ipairs(self.text) do
      g.setColor(COLORS[c.color])
      g.print(c.char, c.x, c.y)
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
    x = (self.j+1)*_TILE_W + self.x_margin
  elseif self.side == "left" then
    x = self.j*_TILE_W -self.x_margin - w
  else
    error("not a valid side for dialogue box")
  end

  local fx_offset = math.sin(love.timer.getTime() * _FX_SPEED) * _FX_MAGNITUDE
  y = (self.i+.5)*_TILE_H - h/2 + self.y_offset + fx_offset

  return math.floor(x + .5), math.floor(y + .5)
end

function DialogueBox:getSize()
  local max_x = 0
  for _, c in ipairs(self.text) do
    if max_x < c.x + _font:getWidth(c.char) then
      max_x = c.x + _font:getWidth(c.char)
    end
  end
  local w = math.min(max_x + self.text_margin, self.max_width)
  local h = self.text[#self.text].y + _font:getHeight()
  return w, h
end

function DialogueBox:updateText(dt)
  self.char_timer = self.char_timer + dt
end

function DialogueBox:parseText(text)
  local parsed = {}
  local x = self.text_margin
  local y = 0
  local i = 1

  --Default value
  local time = self.regular_char_time
  local color = self.regular_char_color

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
        if self[effect_value.."_char_time"] then
          time = self[effect_value.."_char_time"]
        else
          err = true
        end
      elseif effect_type == "color" then
        if self[effect_value.."_char_color"] then
          color = self[effect_value.."_char_color"]
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
        color = color
      }
      x = x + w

      --Wrap words
      if x > self.max_width - 2*self.text_margin then
        y = y + _font:getHeight()
        x = self.text_margin
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
