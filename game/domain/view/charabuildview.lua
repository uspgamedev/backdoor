
local Queue = require 'lux.common.Queue'

local CharaBuildView = Class{
  __includes = { ELEMENT }
}

local strf = string.format

function CharaBuildView:init()

  ELEMENT.init(self)

  self.selection = 1
  self.context = false
  self.render_queue = Queue(256)

end

function CharaBuildView:setContext(context_name)
  self.context = context_name
end

function CharaBuildView:setItem(name, data)
  --self.render_queue.push {name, data}
end

function CharaBuildView:select(n)
  self.selection = n
end

function CharaBuildView:draw()
  --
end

return CharaBuildView


