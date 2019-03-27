
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"
local Vec2    = require 'cpml' .vec2

local Node = Class({ __includes = { ELEMENT } })

function Node:init()
  ELEMENT.init(self)
  self.position = Vec2()
  self.parent = nil
  self.children = {}
end

function Node:setPosition(x, y)
  self.position.x = x
  self.position.y = y
end

function Node:getPosition()
  return self.position:unpack()
end

function Node:getGlobalPosition()
  local parent_pos = Vec2.zero
  if self.parent then parent_pos = self.parent:getGlobalPosition() end
  return self.position + parent_pos
end

function Node:getChild(idx)
  return self.children[idx]
end

function Node:findChild(child)
  for idx, ch in ipairs(self.children) do
    if ch == child then
      return idx
    end
  end
end

function Node:addChild(child)
  local index = self:findChild(child) or table.insert(self.children, child)
  child.parent = self
  return index
end

function Node:removeChild(child)
  return table.remove(self.children, self:findChild(child))
end

function Node:process(dt) -- abstract
end

function Node:update(dt)
  self:process(dt)
  for _,child in ipairs(self.children) do
    child:update(dt)
  end
end

function Node:render(g) -- abstract
end

function Node:draw()
  local g = love.graphics
  g.push()
  g.translate(self.position:unpack())
  self:render(g)
  for _,child in ipairs(self.children) do
    child:draw()
  end
  return g.pop()
end

return Node

