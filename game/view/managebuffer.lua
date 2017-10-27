
local View = CLASS({
  __includes = ELEMENT
})

local _ENTER_TIMER = "manage_buffer_enter"

function View:init(actor)
  ELEMENT.init(self)

  self.enter = 0
  self.actor = actor
end

function View:fadeIn()
  self.invisible = false
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                 .2, self, { enter = 1 }, "out-quad")
end

function View:fadeOut()
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                 .2, self, { enter = 1 }, "out-quad",
                 function () self.invisible = true end)
end

function View:draw()

end

return View

