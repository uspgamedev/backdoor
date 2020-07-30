
local FONT    = require 'view.helpers.font'
local RES     = require 'resources'
local PROFILE = require 'infra.profile'
local COLORS  = require 'domain.definitions.colors'

local Class   = require 'steaming.extra_libs.hump.class'
local ELEMENT = require 'steaming.classes.primitives.element'
local vec2    = require 'cpml' .vec2

local ControlHint = Class{
  __includes = { ELEMENT }
}

ControlHint.BUTTON = {
  ACTION_LEFT = 'action_left',
  ACTION_UP = 'action_up',
  ACTION_RIGHT = 'action_right',
  ACTION_DOWN = 'action_down',
  SHOULDER_LEFT = 'shoulder_left',
  SHOULDER_RIGHT = 'shoulder_right',
  action_left = {
    texture_name = 'button-key-action-left',
    hints = { DEFAULT = "Open hand", FOCUS = "Close hand" }
  },
  action_up = {
    texture_name = 'button-key-action-up',
    hints = { DEFAULT = "See packs", FOCUS = "Discard" }
  },
  action_down = {
    texture_name = 'button-key-action-down',
    hints = { DEFAULT = "Wait", FOCUS = "Cancel" }
  },
  action_right = {
    texture_name = 'button-key-action-right',
    hints = { DEFAULT = "Interact", FOCUS = "Play card" }
  },
  shoulder_left = {
    texture_name = 'button-key-shoulder-left',
    hints = { DEFAULT = "Toggle hints", FOCUS = "Toggle hints" }
  },
  shoulder_right = {
    texture_name = 'button-key-shoulder-right',
    hints = { DEFAULT = "(hold) Show stats", FOCUS = "(hold) Show stats" }
  },
}

function ControlHint:init(x, y, specname)
    ELEMENT.init(self)
    self:setSubtype("control_hints")

    local spec = assert(ControlHint.BUTTON[specname], "Unknown button spec")

    self.pos = vec2(x, y)
    self.hints = spec.hints
    self.mode = "DEFAULT"

    self.show = PROFILE.getTutorial("finished_tutorial")
    self.alpha = 0
    self.show_speed = 5
    self.image = RES.loadTexture(spec.texture_name)
    self.image:setFilter("linear")
    self.text_font = FONT.get("Text", 20)
    self.text_font2 = FONT.get("Text", 16)
end

function ControlHint:update(dt)
  if self.show then
    self.alpha = math.min(self.alpha + self.show_speed*dt, 1)
  else
    self.alpha = math.max(self.alpha - self.show_speed*dt, 0)
  end
end

function ControlHint:setMode(mode)
  self.mode = mode
end

function ControlHint:toggleShow()
  self.show = not self.show
end

function ControlHint:draw()
  local text = self.hints[self.mode]
  if text then
    local g = love.graphics -- luacheck: globals love
    local x, y, scale = self.pos.x, self.pos.y, .4
    g.setColor(1,1,1,self.alpha)
    g.draw(self.image, x, y, nil, scale)

    local gap = 4
    local text_y = y + self.image:getHeight()*scale/2
                     - self.text_font:getHeight()/2
    local text_x = x + self.image:getWidth()*scale + gap
    self.text_font:set()
    local c = COLORS.BLACK
    g.setColor(c[1], c[2], c[3], self.alpha)
    g.print(text, text_x + 2, text_y + 2)
    c = COLORS.NEUTRAL
    g.setColor(c[1], c[2], c[3], self.alpha)
    g.print(text, text_x, text_y)
  end
end

return ControlHint
