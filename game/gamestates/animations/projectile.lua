
-- luacheck: globals love MAIN_TIMER

local VIEWDEFS    = require 'view.definitions'
local AnimationFX = require 'view.helpers.animationfx'
local BodyView    = require 'view.sector.bodyview'
local RANDOM      = require 'common.random'

local vec2        = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

function ANIM:script(_, view, report)
  local sectorview = view.sector
  local source = report.actor:getBody()
  local si, sj = source:getPos()
  local ti, tj = unpack(report.target)
  if sectorview:isInsideFov(si, sj) and sectorview:isInsideFov(ti, tj) then
    local sourceview = sectorview:getBodyView(source)
    local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
    local sx, sy = sourceview:getScreenPosition():unpack()
    local dir = BodyView.tileDiffToScreen(ti - si, tj - sj)
    local tx, ty = sx + dir.x, sy + dir.y
    local source_pos = vec2(sx + w/2, sy + h/2 - VIEWDEFS.TILE_H * .75)
    local target_pos = vec2(tx + w/2, ty + h/2 - VIEWDEFS.TILE_H * .75)
    local projectile = AnimationFX("projectile-energy-sphere", source_pos)
    if RANDOM.safeGenerate() > 0.5 then
      dir.x, dir.y = -dir.y, dir.x
    else
      dir.x, dir.y = dir.y, -dir.x
    end
    projectile:addTimer(
      "prepare", MAIN_TIMER, "tween", 0.4, projectile,
      { position = source_pos + dir:normalize() * VIEWDEFS.TILE_H },
      'out-cubic',
      function ()
        self.resume()
      end
    )
    self.wait()
    projectile:addTimer(
      "aim", MAIN_TIMER, "after", 0.2,
      function ()
        self.resume()
      end
    )
    self.wait()
    projectile:addTimer(
      "shoot", MAIN_TIMER, "tween", 0.2, projectile,
      { position = target_pos }, 'in-cubic',
      function ()
        self.resume()
      end
    )
    self.wait()
    projectile:kill()
  end
end

return ANIM
