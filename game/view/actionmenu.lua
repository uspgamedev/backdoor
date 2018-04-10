
local RES = require 'resources'
local CAM = require 'common.camera'
local FONT = require 'view.helpers.font'
local DEFS = require 'domain.definitions'
local COLORS = require 'domain.definitions.colors'

-- CONSTANTS -------------------------------------------------------------------

local _W, _H
local _ANGLE = math.pi/4
local _RADIUS = 196
local _ACTIONS = {
  'interact', 'use_signature', 'activate_widget', 'play_card', 'draw_new_hand',
  'consume_cards_from_buffer', 'receive_pack', 'idle',
  interact = "Interact",
  use_signature = "Signature Ability",
  activate_widget = "Use Widget",
  play_card = "Play Card",
  consume_cards_from_buffer = "Manage Back Buffer",
  draw_new_hand = "Draw New Hand\n(-"..DEFS.ACTION.NEW_HAND_COST.." PP)",
  receive_pack = "Open Card Pack",
  idle = "Wait"
}
local _TWEEN = {
  OPEN_CLOSE = "__OPEN_CLOSE__",
  TEXT = "__TEXT__",
  SWITCH = "__SWITCH__",
}

-- LOCAL VARIABLES -------------------------------------------------------------

local _font
local _tiny_font

-- LOCAL FUNCTION DECLARATIONS -------------------------------------------------

local function _getDisplacedIndex(current, offset, max)
  return (current + max*offset - 1 + offset) % max + 1
end


-- ActionMenu Class ----------------------------------------------------------

local ActionMenu = Class {
  __includes = { ELEMENT }
}

-- CLASS METHODS ---------------------------------------------------------------

function ActionMenu:init()

  ELEMENT.init(self)
  self.current = 1
  self.switch = 0
  self.enter = 0
  self.text = 0
  self.actor = false
  _W, _H = love.graphics.getDimensions()
  _font = _font or FONT.get("Text", 32)
  _tiny_font = _tiny_font or FONT.get("TextBold", 20)

end

function ActionMenu:showLabel()
  local len = #_ACTIONS[_ACTIONS[self.current]]
  self.text = 0
  self:removeTimer(_TWEEN.TEXT, MAIN_TIMER)
  self:addTimer(_TWEEN.TEXT, MAIN_TIMER, "tween",
                0.05 * len, self, { text = len+1 }, 'linear')
end

function ActionMenu:hideLabel()
  self:removeTimer(_TWEEN.TEXT, MAIN_TIMER)
  self:addTimer(_TWEEN.TEXT, MAIN_TIMER, "tween",
                0.05 * self.text, self, { text = 0 }, 'linear')
end

function ActionMenu:moveFocus(dir)
  local last = self.current
  local item_count = #_ACTIONS
  local offset = 0
  if dir == 'UP' or dir == 'RIGHT' or dir == 'UPRIGHT' then
    offset = -1
  elseif dir == 'DOWN' or dir == 'LEFT' or dir == 'DOWNLEFT' then
    offset = 1
  end
  self.current = _getDisplacedIndex(self.current, offset, item_count)
  if last ~= self.current then
    local k = last - self.current
    if k > item_count / 2 then
      k = k - item_count
    elseif k < -item_count / 2 then
      k = k + item_count
    end
    self.switch = k
    self:removeTimer(_TWEEN.SWITCH, MAIN_TIMER)
    self:addTimer(_TWEEN.SWITCH, MAIN_TIMER, "tween",
                  0.3, self, { switch = 0 }, 'out-back')
    self:showLabel()
  end
end

function ActionMenu:getCurrentFocus()
  return self.current
end

function ActionMenu:getSelected()
  return _ACTIONS[self.current]
end

function ActionMenu:open(last_focus, actor)
  self.actor = actor
  self.invisible = false
  self:removeTimer(_TWEEN.OPEN_CLOSE, MAIN_TIMER)
  self:addTimer(_TWEEN.OPEN_CLOSE, MAIN_TIMER, "tween", 0.3,
                self, { enter = 1 }, 'out-circ'
  )
  self.current = last_focus or self.current
  self:showLabel()
end

function ActionMenu:close()
  self:removeTimer(_TWEEN.OPEN_CLOSE, MAIN_TIMER)
  self:addTimer(_TWEEN.OPEN_CLOSE, MAIN_TIMER, "tween", 0.3,
                self, { enter = 0 }, 'out-circ', function()
                  self.invisible = true
                  CAM:zoomTo(1)
                end
  )
  self:hideLabel()
end

function ActionMenu:draw()
  local g = love.graphics
  local enter = self.enter
  local switch = self.switch
  local cos, sin, pi = math.cos, math.sin, math.pi
  local min, max, abs = math.min, math.max, math.abs
  CAM:zoomTo(1 + enter)
  g.push()
  g.translate(_W/2, _H/2 - 40)
  local rot = (enter - 1) * pi + switch * _ANGLE
  local item_count = #_ACTIONS
  local start = _getDisplacedIndex(self.current, -3, item_count)
  local finish = _getDisplacedIndex(self.current, 3, item_count)
  local i = start
  while i ~= finish do
    local action_name = _ACTIONS[i]
    local k = i - self.current
    if k > item_count / 2 then
      k = k - item_count
    elseif k < -item_count / 2 then
      k = k + item_count
    end
    local angle = rot - _ANGLE*k
    local x,y = cos(angle), -sin(angle)
    local size = (i == self.current) and (1 - abs(switch)/2) or 0.5
    local fade = max(0, min(1, 1 - abs(angle)/(pi*0.6)))
    g.push()
    g.translate(_RADIUS*x, _RADIUS*y)
    g.setColor(80/255, 10/255, 50/255, enter*fade*100/255)
    g.circle("fill", 8, 8, 64*size)
    g.setColor(230/255, 180/255, 60/255, enter*fade)
    g.circle("fill", 0, 0, 64*size)
    g.setColor(1, 1, 1, enter*fade)
    g.draw(RES.loadTexture('icon-' .. action_name), 0, 0, 0, 1/4*size, 1/4*size,
           256, 256)
    if action_name == 'receive_pack' and self.actor then
      local pack_count = self.actor:getPrizePackCount()
      if pack_count > 0 then
        local count_str = tostring(pack_count)
        local w = _tiny_font:getWidth(count_str)
        local h = _tiny_font:getHeight()
        local cr, cg, cb = unpack(COLORS.NOTIFICATION)
        g.push()
        g.translate(64*size*cos(pi/4), 64*size*sin(pi/4))
        g.scale(size)
        g.setColor(cr, cg, cb, enter*fade)
        g.circle("fill", 0, 0, 20, 20)
        cr, cg, cb = unpack(COLORS.NEUTRAL)
        g.setColor(cr, cg, cb, enter*fade)
        _tiny_font:setLineHeight(1)
        _tiny_font.set()
        g.printf(count_str, -w/2, -1.1*h/2, w, "center")
        g.pop()
      end
    end
    g.pop()

    i = _getDisplacedIndex(i, 1, item_count)
  end
  g.push()
  _font:setLineHeight(1)
  _font.set()
  g.translate(_RADIUS, 0)
  g.setColor(1, 1, 1, enter)
  local label = _ACTIONS[_ACTIONS[self.current]]
  g.print(label:sub(1, self.text), 64, 64)
  g.pop()
  g.pop()
end

return ActionMenu
