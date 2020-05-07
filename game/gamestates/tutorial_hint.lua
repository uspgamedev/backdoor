local state    = {}
local Util     = require "steaming.util"
local SWITCHER = require 'infra.switcher'
local FONT     = require 'view.helpers.font'
local COLORS   = require 'domain.definitions.colors'
local VIEWDEFS = require 'view.definitions'
local PROFILE  = require 'infra.profile'
local Draw     = require "draw"

--[[ LOCAL VARIABLES ]]--

local SPEED = 4
local HINTS = {
  open_hand = {
    {
      text = "To activate or deactivate your hand press A",
      region = {x = 400, y = 690, w = 600, h = 200},
      text_pos = {x = 400, y = 630}
    }
  },
  use_card = {
    {
      text = "To use a card press F",
      region = {x = 400, y = 550, w = 600, h = 200},
      text_pos = {x = 400, y = 400}
    },
    {
      text = "Unless the card is consumable, it will go to your backbuffer after use",
      region = {x = 600, y = 690, w = 600, h = 200},
      text_pos = {x = 40, y = 80}
    }
  }
}

local _font = FONT.get("Text", 25)
local _hint_data
local _cur_hint
local _alpha
local _leaving

--[[ LOCAL FUNCTIONS ]]--

local stencilFunc

--[[ STATE FUNCTIONS ]]--

function state:enter(_, hint)
  _alpha = 0
  _leaving = false
  PROFILE.setTutorial(hint, true)
  if not HINTS[hint] then
    error("Not a valid hint type: " .. tostring(hint))
  end
  _cur_hint = 1
  _hint_data = HINTS[hint]
end

function state:leave()
  Util.destroyAll()
end

function state:update(dt)
  if not _leaving then
    _alpha = math.min(_alpha + dt*SPEED, 1)
  else
    _alpha = math.max(_alpha - dt*SPEED, 0)
    if _alpha <= 0 then
      SWITCHER:pop()
    end
  end
end

function state:keypressed()
  if _leaving or _alpha < 1.0 then
    return
  end
  if not _hint_data[_cur_hint + 1] then
    _leaving = true
  else
    _cur_hint = _cur_hint + 1
  end
end

function state:draw()
  Draw.allTables()

  local g = love.graphics


  --Draw black filter
  g.stencil(stencilFunc, "replace", 1)
  g.setStencilTest("less", 1)
  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  g.setColor(0,0,0,.8*_alpha)
  g.rectangle("fill", 0, 0, w, h)
  g.setStencilTest()

  --Draw text
  local c = COLORS.NEUTRAL
  g.setColor(c[1], c[2], c[3], _alpha)
  _font:set()
  local pos = _hint_data[_cur_hint].text_pos
  g.print(_hint_data[_cur_hint].text, pos.x, pos.y - 30)

end

--Local functions

function stencilFunc()
    local g = love.graphics
    local r = _hint_data[_cur_hint].region
    g.rectangle("fill", r.x, r.y, r.w, r.h)
end

return state
