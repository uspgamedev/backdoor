local state    = {}
local Util     = require "steaming.util"
local SWITCHER = require 'infra.switcher'
local FONT     = require 'view.helpers.font'
local COLORS   = require 'domain.definitions.colors'
local VIEWDEFS = require 'view.definitions'
local Draw     = require "draw"

--[[ LOCAL VARIABLES ]]--

local HINTS = {
  open_hand = {
    {
      text = "To activate or deactivate your hand press A",
      region = {x = 400, y = 690, w = 600, h = 200},
      text_pos = {x = 400, y = 630}
    }
  }
}

local _font = FONT.get("Text", 25)
local _hint_data
local _cur_hint

--[[ LOCAL FUNCTIONS ]]--

local stencilFunc

--[[ STATE FUNCTIONS ]]--

function state:enter(_, hint)
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

end

function state:keypressed()
  _cur_hint = _cur_hint + 1
  if not _hint_data[_cur_hint] then
    SWITCHER:pop()
  end
end

function state:draw()
  Draw.allTables()

  local g = love.graphics

  if _hint_data[_cur_hint] then
    --Draw black filter
    g.stencil(stencilFunc, "replace", 1)
    g.setStencilTest("less", 1)
    local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
    g.setColor(0,0,0,.7)
    g.rectangle("fill", 0, 0, w, h)
    g.setStencilTest()

    --Draw text
    g.setColor(COLORS.NEUTRAL)
    _font:set()
    local pos = _hint_data[_cur_hint].text_pos
    g.print(_hint_data[_cur_hint].text, pos.x, pos.y - 30)
  end
end

--Local functions

function stencilFunc()
    local g = love.graphics
    local r = _hint_data[_cur_hint].region
    g.rectangle("fill", r.x, r.y, r.w, r.h)
end

return state
