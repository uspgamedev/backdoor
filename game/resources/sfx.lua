local Class = require "steaming.extra_libs.hump.class"

local Sfx = {}

local Source = Class({})

function Source:init(path, polyphony)
    assert(polyphony > 0, "Not a valid polyphony value")
    self.buffer_size = polyphony

    self.buffer = {}
    for i = 1, self.buffer_size do
      self.buffer[i] = love.audio.newSource(path, "static")
    end

    self.next_index = 1
end

function Source:play()
<<<<<<< HEAD
<<<<<<< HEAD
    local source = self.buffer[self.next_index]
    source:play()
    self.next_index = (self.next_index % self.buffer_size) + 1
    return source
end

function Source:setVolume(vol)
  for i = 1, self.buffer_size do
    self.buffer[i]:setVolume(vol)
  end
=======
    self.buffer[self.next_index]:play()
    self.last_index = self.next_index
    self.next_index = (self.next_index % self.buffer_size) + 1
    return self.last_index
>>>>>>> Some improvements to code
=======
    local source = self.buffer[self.next_index]
    source:play()
    self.next_index = (self.next_index % self.buffer_size) + 1
    return source
>>>>>>> Removed unnecessary last_index variable
end

function Source:seek(vol)
  for i = 1, self.buffer_size do
    self.buffer[i]:setVolume(vol)
  end
end

function Source:getVolume()
    return self.buffer[1]:getVolume()
end

---------------------------------

function Sfx.new(path, polyphony)
  return Source(path, polyphony)
end

return Sfx
