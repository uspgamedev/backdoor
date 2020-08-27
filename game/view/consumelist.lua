
-- luacheck: globals MAIN_TIMER love

local math     = require 'common.math'
local HoldBar  = require 'view.helpers.holdbar'
local CARD     = require 'view.helpers.card'
local FONT     = require 'view.helpers.font'
local COLORS   = require 'domain.definitions.colors'
local DEFS     = require 'domain.definitions'
local CardView = require 'view.card'
local VIEWDEFS = require 'view.definitions'
local Class    = require "steaming.extra_libs.hump.class"
local Dissolve = require 'view.dissolvecard'
local Util     = require "steaming.util"
local ELEMENT  = require "steaming.classes.primitives.element"
local vec2     = require 'cpml' .vec2

-- MODULE -----------------------------------
local View = Class({
  __includes = ELEMENT
})

-- CONSTS -----------------------------------
local _EMPTY = {}
local _ENTER_TIMER = "manage_card_list_enter"
local _TEXT_TIMER = "manage_card_list_text"
local _ENTER_SPEED = .2
local _CENTER_ALPHA_SPEED = 6
local _MOVE_SMOOTH = 1/5
local _EPSILON = 2e-5
local _PD = 40
local _H_MARGIN = 30
local _V_MARGIN = 10
local _DESC_LINES = 4
local _WAIT_TIME = 2
local _DESC_SCROLL_SPEED = 20
local _BACKBUFFER_OFFSET = vec2(-441, -507)
local _FULL_WIDTH, _WIDTH, _HEIGHT
local _LIST_VALIGN
local _CW, _CH
local _DESC_MAXW

-- LOCAL VARS
local _font
local _titlefont
local _subtitlefont

-- LOCAL METHODS ----------------------------
local function _initGraphicValues()
  local g = love.graphics
  _FULL_WIDTH, _HEIGHT = g.getDimensions()
  _WIDTH = _FULL_WIDTH*3/4
  _LIST_VALIGN = 0.5*_HEIGHT
  _font = FONT.get("TextBold", 20)
  _titlefont = FONT.get("Text", 64)
  _subtitlefont = FONT.get("Text", 35)
  _CW = CARD.getWidth()
  _CH = CARD.getHeight()
  _DESC_MAXW = 2*_CW
end

local function _descriptionStencil()
  love.graphics.rectangle("fill", -2*_CW - _PD, -CARD.getInfoHeight(_DESC_LINES)/2,
                          2*(2*_CW + _PD), CARD.getInfoHeight(_DESC_LINES))

end

local function _stencil(self)
  local margin = 4
  --Panel region
  love.graphics.rectangle("fill", _FULL_WIDTH - VIEWDEFS.PANEL_W - margin,
                          _HEIGHT - 448 - margin, VIEWDEFS.PANEL_W + margin,
                          VIEWDEFS.PANEL_H + margin)
  --Backbuffer region
  local w, h = 120*self.backbuffer_show, 160*self.backbuffer_show
  love.graphics.rectangle("fill", _FULL_WIDTH - w, _HEIGHT - h, w, h)
end

local function _next_circular(i, len, n)
  if n == 0 then return i end
  return _next_circular(i % len + 1, len, n - 1)
end

local function _prev_circular(i, len, n)
  if n == 0 then return i end
  return _prev_circular((i - 2) % len + 1, len, n - 1)
end

--Sort cardlist alphabetically and returns a mapping function to this order
local function _sort_card_list(cardlist)
  local map = {}
  --Insertion sort
  for i, card in ipairs(cardlist) do
    local name = card:getName()
    local j = 1
    while j <= #map do
      if cardlist[map[j]]:getName() >= name then break end
      j = j + 1
    end
    table.insert(map, j, i)
  end

  return map
end

-- PUBLIC METHODS ---------------------------
function View:init(hold_actions)
  ELEMENT.init(self)

  self.enter = 0
  self.center_alpha = 1
  self.text = 0
  self.selection = 1
  self.buffered_offset = {}
  self.card_alpha = {}
  self.move = self.selection
  self.offsets = {}
  self.card_list = _EMPTY
  self.card_map = _EMPTY
  self.consumed = {}
  self.consumed_count = 0
  self.consume_log = false
  self.holdbar = HoldBar(hold_actions)
  self.holdbar:setScale(3,2)
  self.exp_gained = 0
  self.ready_to_leave = false
  self.is_leaving = false
  self.send_to_backbuffer = false
  self.backbuffer = nil
  self.backbuffer_show = 0
  self.desc_offset = 0
  self.show_bouncing_arrow = false

  _initGraphicValues()
end

function View:isLocked()
  return self.holdbar:isLocked()
end

function View:open(card_list, maxconsume)
  self.card_map = _sort_card_list(card_list)
  self.card_list = {}
  for i, v in ipairs(self.card_map) do
    local card = card_list[v]
    self.card_list[i] = CardView(card)
    self.card_list[i]:setAlpha(0.9)
  end
  self.consume_log = {}
  self.holdbar:unlock()
  self.selection = math.ceil(#card_list/2)
  self.maxconsume = maxconsume
  for i=1,#card_list do
    self.buffered_offset[i] = 0
    self.card_alpha[i] = 1
    self.consumed[i] = false
  end
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=1, text=1 }, "out-quad")
  self:resetDescriptionScrolling()
end

function View:lockHoldbar()
  self.holdbar:lock()
end

function View:unlockHoldbar()
  self.holdbar:unlock()
end

function View:close()
  self.holdbar:lock()
  self.consume_log = _EMPTY
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  Util.findId('actorpanel-stats'):setExpPreview()
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=0, text=0}, "out-quad",
                function ()
                  self.card_list = _EMPTY
                  self:destroy()
                end)
end

function View:selectPrev(n)
  if self:isLocked() then return end
  n = n or 1
  self.selection = _prev_circular(self.selection, #self.card_list, n)
  self.holdbar:reset()
  self:resetDescriptionScrolling()
end

function View:selectNext(n)
  if self:isLocked() then return end
  n = n or 1
  self.selection = _next_circular(self.selection, #self.card_list, n)
  self.holdbar:reset()
  self:resetDescriptionScrolling()
end

function View:setSelection(n)
  self.selection = n
  self:resetDescriptionScrolling()
end

function View:startLeaving()
  self.holdbar:lock()
  self.is_leaving = true
  self:addTimer(_TEXT_TIMER, MAIN_TIMER, "tween", _ENTER_SPEED,
                self, {text=0}, "in-quad")
  if self.send_to_backbuffer then
    self:addTimer(_TEXT_TIMER, MAIN_TIMER, "tween", .25,
                  self, {backbuffer_show=1}, "in-quad")
  end
  for i = 1, #self.card_list do
    self:addTimer(
      "collect_card_"..i, MAIN_TIMER, "after", i*5/60 + .05,
      function()
        if not self.consumed[i] then
          if self.send_to_backbuffer then
            local backbuffer = self.backbuffer
            local finish = backbuffer:getTopCardPosition(i-1)
            local cardview = self.card_list[i]
            local offset = _BACKBUFFER_OFFSET - vec2((i-1)*(_CW+_PD)
                         - math.round((_CW+_PD)*(self.move-1)),0)
            self:addTimer("slide_card_"..i, MAIN_TIMER, "tween", .5,
                          cardview, {position = finish + offset},
                          'out-cubic')
            self:addTimer(
              "wait_card_"..i, MAIN_TIMER, "after", .3,
               function()
                 self:addTimer("add_fakecard_"..i, MAIN_TIMER, "after", .15,
                               function()
                                 backbuffer:addFakeCard()
                               end)
                 self:addTimer("fadeout_card_"..i, MAIN_TIMER, "tween", .3,
                               cardview, {alpha = 0}, 'out-cubic',
                               function() cardview:destroy() end)
               end
             )
          else
            self:addTimer("getting_card_"..i, MAIN_TIMER,
                          "tween", .3, self.buffered_offset,
                          {[i] = _HEIGHT}, "in-back")
          end
        else
          Dissolve(self.card_list[i], .5)
        end
      end
    )
  end
  local d = self.send_to_backbuffer and 1.2 or .75
  self:addTimer("finish_collection", MAIN_TIMER, "after", d,
                function()
                  if self.backbuffer then
                    self.backbuffer:resetFakeCards()
                  end
                  self.ready_to_leave = true
                end)

end

function View:isReadyToLeave()
  return self.ready_to_leave
end

function View:toggleSelected()

  if self.consumed[self.selection] then
    self:removeConsume()
    self.consumed[self.selection] = not self.consumed[self.selection]
  elseif not self.maxconsume or self.consumed_count < self.maxconsume then
    self:addConsume()
    self.consumed[self.selection] = not self.consumed[self.selection]
  end

end

function View:getConsumeLog()
  local t = {}
  for i, consumed in ipairs(self.consumed) do
    if consumed then
      table.insert(t,self.card_map[i])
    end
  end
  table.sort(t)
  return t
end

function View:getExpGained()
  return self.exp_gained
end

function View:addConsume()
  self.exp_gained = self.exp_gained + 1
  self.consumed_count = self.consumed_count + 1
  Util.findId('actorpanel-stats'):setExpPreview(self.exp_gained *
                                                DEFS.CONSUME_EXP)
end

function View:removeConsume()
  self.exp_gained = self.exp_gained - 1
  self.consumed_count = self.consumed_count - 1
  Util.findId('actorpanel-stats'):setExpPreview(self.exp_gained *
                                                DEFS.CONSUME_EXP)
end

function View:stopDescriptionScrolling()
  self.desc_offset = 0
  self.show_bouncing_arrow = false
  self:removeTimer("initial_wait", MAIN_TIMER)
  self:removeTimer("scrolling_desc", MAIN_TIMER)
  self:removeTimer("finish_wait", MAIN_TIMER)
  self:removeTimer("scroll_up", MAIN_TIMER)
end

function View:destroy()
  self:stopDescriptionScrolling()
  ELEMENT.destroy(self)
end

function View:resetDescriptionScrolling()
  self:stopDescriptionScrolling()
  local card = self.card_list[self.selection].card
  if CARD.getInfoLines(card, 2*_DESC_MAXW) > _DESC_LINES then
    self:startDescriptionScrolling()
  end
end

function View:startDescriptionScrolling()
  self.show_bouncing_arrow = true
  self:addTimer("initial_wait", MAIN_TIMER, "after", _WAIT_TIME,
    function()
      local card = self.card_list[self.selection].card
      local target_off = -CARD.getInfoHeight(CARD.getInfoLines(card, 2*_DESC_MAXW) - _DESC_LINES)
      local d = math.abs(target_off/_DESC_SCROLL_SPEED)
      self:addTimer(
        "scrolling_desc", MAIN_TIMER, "tween", d, self,
        {desc_offset = target_off}, "in-linear",
        function()
          self.show_bouncing_arrow = false
          self:addTimer(
            "finish_wait", MAIN_TIMER, "after", _WAIT_TIME,
            function()
              local dd = math.abs(target_off/(_DESC_SCROLL_SPEED*15))
              self:addTimer(
                "scroll_up", MAIN_TIMER, "tween", dd, self, {desc_offset = 0},
                "out-quad",
                function()
                    self.desc_offset = 0
                    self:startDescriptionScrolling()
                end
              )
            end
          )
        end
      )
    end
  )
end

function View:update(dt)
  if self.holdbar.is_playing then
    self.center_alpha = math.max(0, self.center_alpha - _CENTER_ALPHA_SPEED*dt)
  else
    self.center_alpha = math.min(self.center_alpha + _CENTER_ALPHA_SPEED*dt, 1)
  end
  for _,card in ipairs(self.card_list) do
    card:update(dt)
  end
end

function View:draw()
  local g = love.graphics
  local enter = self.enter
  g.push()

  if enter > 0 then
    self:drawBG(g, enter)
    self:drawCards(g, enter)
  end

  g.pop()
end

function View:drawBG(g, enter)
  g.setColor(0, 0, 0, enter*0.95)
  love.graphics.stencil(function() _stencil(self) end, "replace", 1)
  love.graphics.setStencilTest("less", 1)
  g.rectangle("fill", 0, 0, _FULL_WIDTH, _HEIGHT)
  love.graphics.setStencilTest()
end

function View:drawCards(g, enter)
  local selection = self.selection
  local card_list = self.card_list
  local card_list_size = #card_list

  g.push()

  -- smooth enter!
  g.translate(math.round((_WIDTH/2)*(1-enter)+_WIDTH/2-_CW/2),
              math.round(2*_HEIGHT/7-_CH/2))

  -- smooth movement!
  self.move = self.move + (selection - self.move)*_MOVE_SMOOTH
  if (self.move-selection)^2 <= _EPSILON then self.move = selection end
  g.translate(math.round(-(_CW+_PD)*(self.move-1)), 0)

  -- draw each card
  for i = 1, card_list_size do
    g.push()
    local focus = selection == i
    local dist = math.abs(selection-i)
    local offset = self.offsets[i] or 0
    local consumed = self.consumed[i] and _LIST_VALIGN or 0

    -- smooth offset when consuming cards
    offset = offset > _EPSILON and offset - offset * _MOVE_SMOOTH or 0
    self.offsets[i] = offset
    g.translate((_CW+_PD)*(i-1+offset), _LIST_VALIGN - consumed)
    g.translate(0, self.buffered_offset[i])
    local card = card_list[i]
    card:setFocus(focus and not self.is_leaving)
    if not self.is_leaving then
      card:setAlpha(dist > 0 and enter/dist*self.card_alpha[i]
                              or enter*self.card_alpha[i])
    end
    card:draw()
    g.pop()
  end
  g.pop()

  -- draw selection
  g.push()
  g.translate(math.round(_WIDTH/2),
              math.round(_HEIGHT/2))
  enter = self.text
  local owner
  if enter > 0 then
    if card_list[selection] then
      owner = card_list[selection].card:getOwner()
      self:drawCardDesc(g, card_list[selection], enter)
    end
  end
  g.pop()

  -- draw hud info
  self:drawHUDInfo(g, owner, enter)

end

function View:drawCardDesc(g, card, enter)
  g.push()

  g.setLineWidth(2)

  --Draw lines besides description
  g.setColor(COLORS.NEUTRAL[1], COLORS.NEUTRAL[2], COLORS.NEUTRAL[3], enter)
  g.line(-0.45*_WIDTH, 0, -_DESC_MAXW - _PD, 0)
  g.line(_DESC_MAXW + _PD, 0, 0.45*_WIDTH, 0)

  --Draw holdbar
  local x, y = 0, -self.holdbar:getHeight()/2
  self:drawHoldBar(g, enter * (1 - self.center_alpha), x, y)

  g.push()

  --Draw bouncing arrow if description is too big
  local lines = CARD.getInfoLines(card.card, 2*_DESC_MAXW)
  if self.show_bouncing_arrow and lines > _DESC_LINES then
    local off = math.sin(5*love.timer.getTime())*5
    local tmargin, tsize, ty = 10, 10, CARD.getInfoHeight(_DESC_LINES)/2 + off
    g.polygon("fill", _DESC_MAXW + _PD - tsize - tmargin, ty,
                       _DESC_MAXW + _PD - tmargin, ty,
                       _DESC_MAXW + _PD - tsize/2 - tmargin, ty + tsize)
  end

  --Draw card description
  g.stencil(_descriptionStencil, "replace", 1)
  g.setStencilTest("equal", 1)
  g.translate(-_DESC_MAXW, -CARD.getInfoHeight(_DESC_LINES)/2 + self.desc_offset)
  CARD.drawInfo(card.card, 0, 0, 2*_DESC_MAXW, enter*self.center_alpha, nil, true)
  g.setStencilTest()
  g.pop()

  g.pop()
end

function View:drawHUDInfo(g, owner, enter)

    --Draw keep side
    g.setColor(COLORS.NEUTRAL[1], COLORS.NEUTRAL[2], COLORS.NEUTRAL[3], enter)
    _titlefont.set()
    g.print("Keep", _H_MARGIN, _HEIGHT - _V_MARGIN - _titlefont:getHeight())

    --Draw consume side
    local consume_text = "Consume"
    g.print(consume_text, _H_MARGIN, _V_MARGIN)
    if self.maxconsume then
      local text = ("%d/%d"):format(self.consumed_count, self.maxconsume)
      _subtitlefont.set()
      local gap = 10
      g.print(text, _H_MARGIN + _titlefont:getWidth(consume_text) + gap,
                    _V_MARGIN + _titlefont:getHeight()
                              - _subtitlefont:getHeight())
    end


    --Draw distribution
    if owner then
      local cor, arc, ani = owner:trainingDistribution()
      local cor_t = ("%.1f%%"):format(cor*100)
      local arc_t = ("%.1f%%"):format(arc*100)
      local ani_t = ("%.1f%%"):format(ani*100)
      _font.set()
      g.setColor(COLORS.COR[1], COLORS.COR[2], COLORS.COR[3], enter*enter*enter)
      g.print(cor_t, _WIDTH + 57, _HEIGHT - 308)
      g.setColor(COLORS.ARC[1], COLORS.ARC[2], COLORS.ARC[3], enter*enter*enter)
      g.print(arc_t, _WIDTH + 133, _HEIGHT - 308)
      g.setColor(COLORS.ANI[1], COLORS.ANI[2], COLORS.ANI[3], enter*enter*enter)
      g.print(ani_t, _WIDTH + 209, _HEIGHT - 308)
    end

end

function View:drawHoldBar(g, alpha, x, y)
  g.push()
  g.setColor(1, 1, 1, alpha)
  self.holdbar:update()
  if self.holdbar:confirmed() then
    self:startLeaving()
  end
  self.holdbar:draw(x, y)
  g.pop()
end

function View:sendToBackbuffer(backbuffer)
  self.send_to_backbuffer = true
  self.backbuffer = backbuffer
end

return View
