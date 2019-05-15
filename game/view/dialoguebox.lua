
local Class    = require "steaming.extra_libs.hump.class"
local VIEWDEFS = require 'view.definitions'
local ELEMENT  = require "steaming.classes.primitives.element"
local COLORS   = require 'domain.definitions.colors'
local FONT     = require 'view.helpers.font'
local RES      = require 'resources'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

--Speed when box is changing sides
local _MOVE_SPEED = .15

--Oscillating fx on dialogue box
local _FX_MAGNITUDE = 6
local _FX_SPEED = 2.5

--Box attributes
local _X_MARGIN = _TILE_W/6
local _Y_OFFSET = -_TILE_H/3
local _MAX_WIDTH = 2*_TILE_W

--Text attributes
local _TEXT_MARGIN = 5

--Different fonts a char can have
local _CHAR_FONT = {
  small = FONT.get('Text', 12),
  regular = FONT.get('Text', 20),
  big = FONT.get('Text', 25),
}

--Time a character must stay active before next one appears
local _CHAR_SPEED = {
  slow      = .5,
  medium    = .12,
  regular   = .07,
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

--Opacity for a character color
local _CHAR_OPACITY = {
  regular = 1,
  semi    = .7
}

--Wave style consts
local _WAVE_MAGNITUDE = 2
local _WAVE_SPEED = 5
local _WAVE_REGULATOR = 10

--Shake style consts
local _SHAKE_MAGNITUDE = 1

--Forward declaration for local functions
local parseTag
local interpretateTag
local addCharacter
local addImage
local wrapIfNeeded

--[[
HOW TEXT AND TAGS WORK

You can create a stylized text using tags.
Tags are made of one or more attributes, following the pattern:

[attribute1/attribute2/.../attributeX]

Each attribute defines a characteristic for the effect you want to apply.
An attribute follows the pattern:

identifier:value

(IMPORTANT: All tags must have the main attribute 'type')

Example of a stylized "hello world", where the 'hello' is red:

"[type:color/value:red]Hello[type:color/value:regular] world!"
-----------------------------------------------------------

Below is a list of possible effects, detailed as followed:

type_of_effect - what it does
  identifier1 - what it does
    possible_value1 - what it does
    possible_value2 - what it does
    ...
    possible_valueN - what it does

===================LIST OF EFFECTS=========================

speed - set current speed the text should appear
  value - what speed to set
    slow      - slowest speed
    medium    - slower than regular speed
    regular   - regular speed
    fast      - fast speed
    ultrafast - fastest speed

style - set current style for the text
  value - what style to apply
    none  - remove any style
    wave  - wave-like text
    shake - characters will shake frenetically

color - set current color to draw text
  value - what color to use
    regular - default color (white)
    red     - red color
    blue    - blue color
    green   - green color

size - size of font to draw text
  value - what size to use
    small   - smol-sized font
    regular - default font size
    big     - big font for big bois

opacity - Set opacity to draw text
  value - what style to use
    regular - totally opaque
    semi    - semi-transparent

image - Will draw an image on your text
  id - identifier for image (just as it is used in the database)
    <any string> -- will search for an image in the db with this name to draw
  scale - (optional) defines a scale to apply when drawing this image
    <any number value> - set scale for this value
pause - Wait an amount of time before continuing text
  value - how long to pause
    <any number value> - will wait this much time

endl - Create a given amount of linebreaks
  value - number of lines to break
    <any number value> - will break this much lines

============================================================

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

  self.text_line_h = 4*_CHAR_FONT.regular:getHeight()/5
  self.text_start_up_time = .15

  self.text = self:stylizeText(body:getDialogue())

  --Dialogue box position attributes
  self.i = i
  self.j = j
  self.side = side
  local x, y = self:getTargetPosition()
  self.pos = {x = x, y = y}

end

function DialogueBox:draw()
  local g = love.graphics
  local dt = love.timer.getDelta()

  g.push()

  --Move box to target position
  local tx, ty = self:getTargetPosition()
  local eps = 1
  self.pos.x = self.pos.x + (tx - self.pos.x)*_MOVE_SPEED
  if math.abs(self.pos.x - tx) <= eps then self.pos.x = tx end
  self.pos.y = self.pos.y + (ty - self.pos.y)*_MOVE_SPEED
  if math.abs(self.pos.y - ty) <= eps then self.pos.y = ty end

  g.translate(self.pos.x, self.pos.y)

  --Draw bg
  local w, h = self:getSize()
  g.setColor(COLORS.HUD_BG)
  g.rectangle("fill", 0, 0, w, h)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(3)
  g.rectangle("line", 0, 0, w, h)

  --Draw text
  self:updateText(dt)
  local t = self.text_start_up_time
  if t < self.char_timer then
    for i, c in ipairs(self.text) do
      local ox, oy = 0, 0
      if     c.style == "wave" then
        oy = math.sin((love.timer.getTime() + i/_WAVE_REGULATOR) * _WAVE_SPEED) * _WAVE_MAGNITUDE
      elseif c.style == "shake" then
        ox = math.random()*2*_SHAKE_MAGNITUDE - _SHAKE_MAGNITUDE
        oy = math.random()*2*_SHAKE_MAGNITUDE - _SHAKE_MAGNITUDE
      end
      if c.type == "character" then
        local color = COLORS[c.color]
        g.setColor(color[1], color[2], color[3], c.opacity)
        c.font:set()
        g.print(c.object, c.x + ox, c.y + oy)
      elseif c.type == "image" then
        g.setColor(1.0, 1.0, 1.0, c.opacity)
        g.draw(c.object, c.x + ox, c.y + oy, nil, c.scale)
      else
        error("Not a valid type for object: " .. c.type)
      end
      t = t + c.time
      if t > self.char_timer then break end
    end
  end

  g.pop()
end

function DialogueBox:setSide(side)
  self.side = side
end

function DialogueBox:getTargetPosition()
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
  local max_x, max_y = 0, 0
  for _, c in ipairs(self.text) do
    if max_x < c.x + c.width then
      max_x = c.x + c.width
    end
    if max_y < c.y + c.height then
      max_y = c.y + c.height
    end
  end
  local w = math.min(max_x + _TEXT_MARGIN, _MAX_WIDTH)
  local h = max_y + _TEXT_MARGIN
  return w, h
end

function DialogueBox:updateText(dt)
  self.char_timer = self.char_timer + dt
end

function DialogueBox:stylizeText(text)
  local parsed = {}

  --Default values
  local attributes = {
    x = _TEXT_MARGIN,
    y = _TEXT_MARGIN,
    time = _CHAR_SPEED.regular,
    color = _CHAR_COLOR.regular,
    opacity = _CHAR_OPACITY.regular,
    style = "none",
    font = _CHAR_FONT.regular,
  }

  local i = 1
  while i <= text:len() do
    local char = text:sub(i,i)

    --Special tag
    if char == "[" then

      --Get effect
      local data = parseTag(text, i)

      --Apply effect
      interpretateTag(data, attributes, self, parsed)

      --Update text
      text = data.text

    --Common character
    else

      addCharacter(char, parsed, attributes, self)

      --Update iterator
      i = i + 1
    end
  end

  return parsed
end

--LOCAL FUNCTIONS--

--Gets a tag effect that starts from given position, and removes that tag from the text
--A tag must follow the pattern [type_of_effect=value]
function parseTag(text, tag_start_pos)
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

  local type --Main attribute
  local aux_att = {} --Auxiliary attributes
  --Iterate through all attributes the tag have
  for att in effect:gmatch("[^/]+") do

    --Parse attribute and extract identifier/value from effect
    local identifier, value = att:match("(%w+):([%w_%-%.]+)")

    if not identifier or not value then
      error("attribute from tag didn't match 'id:value' pattern.\nrelated tag:\n["..effect.."]")
    end
    if identifier == "type" then
      type = value
    else
      aux_att[identifier] = value
    end

  end

  if not type then
    error("tag didn't have the main attribute 'type': \n"..text:sub(tag_start_pos, tag_end_pos))
  end

  --Remove tag from text
  text = text:sub(0, tag_start_pos - 1) .. text:sub(tag_end_pos + 1, -1)


  return {text = text, type = type, aux_att = aux_att}
end

--Apply correspondent effect from data and change correspondent attributes
function interpretateTag(effect_data, attributes, dialogue_box, parsed_text)
  local err = false
  local type = effect_data.type
  local aux_att = effect_data.aux_att --Auxiliary attributes

  if type == "speed" then
    if aux_att["value"] and _CHAR_SPEED[aux_att["value"]] then
      attributes.time = _CHAR_SPEED[aux_att["value"]]
    else
      err = true
    end

  elseif type == "color" then
    if aux_att["value"] and _CHAR_COLOR[aux_att["value"]] then
      attributes.color = _CHAR_COLOR[aux_att["value"]]
    else
      err = true
    end

  elseif type == "style" then
    if aux_att["value"] and
      (aux_att["value"] == "none" or
       aux_att["value"] == "wave" or
       aux_att["value"] == "shake") then
         attributes.style = aux_att["value"]
    else
      err = true
    end

  elseif type == "size" then
    if aux_att["value"] and
      (aux_att["value"] == "small" or
       aux_att["value"] == "regular" or
       aux_att["value"] == "big") then
         attributes.font = _CHAR_FONT[aux_att["value"]]
    else
      err = true
    end

  elseif type == "opacity" then
    if aux_att["value"] and
      (aux_att["value"] == "regular" or
       aux_att["value"] == "semi") then
         attributes.opacity = _CHAR_OPACITY[aux_att["value"]]
    else
      err = true
    end

  elseif type == "image" then
    if aux_att["id"] then
      local image = RES.loadTexture(aux_att["id"])
      addImage(image, aux_att["scale"], parsed_text, attributes, dialogue_box)
    else
      err = true
    end

  elseif type == "pause" then
    if aux_att["value"] and tonumber(aux_att["value"]) then
      local pause_amount = tonumber(aux_att["value"])
      --Increase start-up time in case pause is in the beginning
      if #parsed_text == 0 then
        dialogue_box.text_start_up_time = dialogue_box.text_start_up_time + pause_amount
      --Increase time in latest object of our text
      else
        parsed_text[#parsed_text].time = parsed_text[#parsed_text].time + pause_amount
      end
    else
      err = true
    end

  elseif type == "endl" then
    if aux_att["value"] and tonumber(aux_att["value"]) then
      local lines_amount = tonumber(aux_att["value"])
      attributes.y = attributes.y + lines_amount * dialogue_box.text_line_h
      attributes.x = _TEXT_MARGIN
    else
      err = true
    end

  else
    err = true
  end

  --Check for errors
  if err then
    local err_string = ""
    for id, value in pairs(aux_att) do
      err_string = err_string .. id .. " : " .. value .. "\n"
    end
    error([[Effect invalid!
         type : ]]..type..[[
         ]]..err_string
         )
  end

end

--Add a character to our parsed table
function addCharacter(char, parsed_text, attributes, dialogue_box)
  --Get dimensions for our character
  local w = attributes.font:getWidth(char)
  local h = attributes.font:getHeight(char)

  --Vertically centralize text
  local ty = attributes.y + dialogue_box.text_line_h/2 - h/2

  table.insert(parsed_text,
    {
      type = "character",
      object = char,
      x = attributes.x,
      y = ty,
      width = w,
      height = h,
      time = attributes.time,
      color = attributes.color,
      opacity = attributes.opacity,
      style = attributes.style,
      font = attributes.font
    }
  )
  attributes.x = attributes.x + w

  wrapIfNeeded(parsed_text, attributes, dialogue_box)
end

--Add an image to our parsed table
function addImage(image, scale, parsed_text, attributes, dialogue_box)

  scale = scale and tonumber(scale) or 1

  --Get dimensions for our image
  local w = image:getWidth() * scale
  local h = image:getHeight() * scale

  --Vertically centralize text
  local ty = attributes.y + dialogue_box.text_line_h/2 - h/2

  table.insert(parsed_text,
    {
      type = "image",
      object = image,
      scale = scale,
      x = attributes.x,
      y = ty,
      width = w,
      height = h,
      time = attributes.time,
      color = {1.0,1.0,1.0,1.0},
      opacity = attributes.opacity,
      style = attributes.style,
      font = attributes.font
    }
  )
  attributes.x = attributes.x + w

  wrapIfNeeded(parsed_text, attributes, dialogue_box)
end

function wrapIfNeeded(parsed_text, attributes, dialogue_box)
  --Checks if need wraps
  if attributes.x > _MAX_WIDTH - 2*_TEXT_MARGIN then
    attributes.y = attributes.y + dialogue_box.text_line_h
    attributes.x = _TEXT_MARGIN
    --Find start of current word
    local j = #parsed_text
    while j >= 1 do
      if parsed_text[j].type == "image" or parsed_text[j].object == " " then break end
      j = j - 1
    end
    if j == 0 then error("Word is too damn big") end
    --Fix position of every objectacter
    for k = j+1, #parsed_text do
      local w = parsed_text[k].width
      local h = parsed_text[k].height
      parsed_text[k].x = attributes.x
      parsed_text[k].y = attributes.y + dialogue_box.text_line_h/2 - h/2
      attributes.x = attributes.x + w
    end
  end
end

return DialogueBox
