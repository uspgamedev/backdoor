
-- luacheck: globals love

local SWITCHER    = require 'infra.switcher'
local Class       = require 'steaming.extra_libs.hump.class'

local Profiler = Class{}

local SAMPLES = 10

function Profiler:init()
  self.profiling = {}
  self.last_state = nil
  self.output = io.open("profiling", "w")
end

function Profiler:update(dt)
  local GS = require 'gamestates'
  local state = self.last_state
  self.last_state = SWITCHER.current()
  if state then
    local name = "???"
    for k,v in pairs(GS) do
      if v == state then
        name = k
        break
      end
    end
    if dt > 0.2 then
      local warning = ("%.2f lag on state %s at frame %d\n"):format(
        dt, name, GS[name].frame or -1
      )
      self.output:write(warning)
      print(warning)
      for _, slice in ipairs(self.slices) do
        self.output:write(("%16s: %.3f\n"):format(slice.name, 1000*slice.span))
      end
    end
    local sample = self.profiling[name] or { times = {} , n = 1 }
    sample.times[sample.n] = dt
    sample.n = (sample.n % SAMPLES) + 1
    self.profiling[name] = sample
  end
  self:start()
end

function Profiler:start()
  self.started_at = love.timer.getTime()
  self.slices = { n = 0 }
end

function Profiler:mark(name)
  if not self.slices then return end
  local n = self.slices.n + 1
  local t = love.timer.getTime()
  local dt = t - self.started_at
  self.started_at = t
  self.slices[n] = { span = dt, name = name }
  self.slices.n = n
end

local function average(sample)
  local sum = 0
  for _,time in ipairs(sample.times) do
    sum = sum + time
  end
  return sum / math.max(#sample.times, SAMPLES)
end

function Profiler:draw()
  local g = love.graphics
  g.push()
  g.origin()
  g.setColor(1,1,1)
  local i = 0
  for name,sample in pairs(self.profiling) do
    g.print(("%s: %.2f"):format(name, 1 / average(sample)), 32, 32+i*32)
    i = i + 1
  end
  g.pop()
end

return Profiler()

