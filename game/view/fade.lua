
local FadeView = Class{
  __includes = { ELEMENT }
}

local _FADE_TIME = 0.25
local _FADE_TWEEN = "FADING_TWEEN"
local _FADE_CONFLICT_ERR = [=[
Fade animations conflicting.
Please wait until one of them is finished]=]

--[[ PUBLIC METHODS ]]--

FadeView.STATE_FADED = 1
FadeView.STATE_UNFADED = 0
FadeView.FADE_TIME = _FADE_TIME

function FadeView:init(fade_state)
  ELEMENT.init(self)
  self.fading_in = false
  self.fading_out = false
  self.exception = true
  self.alpha = fade_state or FadeView.STATE_UNFADED
end

function FadeView:fadeOutAndThen(do_a_thing)
  assert(not self.fading_out and not self.fading_in, _FADE_CONFLICT_ERR)
  self.fading_out = true
  self:removeTimer(_FADE_TWEEN, MAIN_TIMER)
  self:addTimer(_FADE_TWEEN, MAIN_TIMER, "tween", _FADE_TIME,
                self, { alpha = 1 }, "linear",
                function()
                  self.fading_out = false
                  do_a_thing()
                end)
end

function FadeView:fadeInAndThen(do_a_thing)
  assert(not self.fading_out and not self.fading_in, _FADE_CONFLICT_ERR)
  self.fading_in = true
  self:removeTimer(_FADE_TWEEN, MAIN_TIMER)
  self:addTimer(_FADE_TWEEN, MAIN_TIMER, "tween", _FADE_TIME,
                self, { alpha = 0 }, "linear",
                function()
                  self.fading_in = false
                  do_a_thing()
                end)
end

function FadeView:draw()
  local g = love.graphics
  g.setColor(0, 0, 0, self.alpha * 0xff)
  g.rectangle("fill", 0, 0, g.getDimensions())
end

return FadeView

