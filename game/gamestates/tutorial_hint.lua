
-- luacheck: globals love, no self

local state    = {}
local Util     = require "steaming.util"
local SWITCHER = require 'infra.switcher'
local FONT     = require 'view.helpers.font'
local COLORS   = require 'domain.definitions.colors'
local VIEWDEFS = require 'view.definitions'
local PROFILE  = require 'infra.profile'
local CAMERA   = require 'common.camera'
local Draw     = require "draw"

--[[ LOCAL VARIABLES ]]--

local BG_SPEED = 2.5
local HINT_SPEED = 4
local HINTS = {
  open_hand = {
    {
      text = "To activate or deactivate your hand press A",
      region = {x = 400, y = 685, w = 500, h = 80},
      text_pos = {x = 400, y = 610}
    }
  },
  use_card = {
    {
      text = "To use a card press F\nTo discard a card press W",
      region = {x = 370, y = 450, w = 530, h = 200},
      text_pos = {x = 150, y = 500}
    },
    {
      text = "You'll need focus to use most cards",
      region = {x = 550, y = 650, w = 250, h = 200},
      text_pos = {x = 400, y = 590}
    },
    {
      text = "Unless the card is consumable,\nit will go to your backbuffer after use",
      region = {x = 1180, y = 560, w = 120, h = 180},
      text_pos = {x = 900, y = 470}
    }
  },
  pp = {
    {
      text = "Food replenishes your \"Play Points\"\n(or PP)",
      region = {x = 0, y = 550, w = 120, h = 180},
      text_pos = {x = 20, y = 490}
    },
    {
      text = "      You'll need PP to reshuffle your backbuffer\ninto your buffer when you run out of cards to draw",
      region = {{x = 1180, y = 560, w = 120, h = 180}, {x = 0, y = 560, w = 120, h = 180}},
      text_pos = {x = 440, y = 590}
    },
  },
  get_pack = {
    {
      text = "                  You got a pack!\nPress W to check your sealed packs",
      region = {x = 0, y = 0, w = 0, h = 0},
      text_pos = {x = 470, y = 330}
    },
  },
  open_pack = {
    {
      text = "Here you can open your sealed pack by holding up",
      region = {x = 300, y = 40, w = 490, h = 400},
      text_pos = {x = 420, y = 420}
    },
  },
  consume = {
    {
      text = "You can choose where every cards goes",
      region = {x = 200, y = 450, w = 600, h = 200},
      text_pos = {x = 440, y = 370}
    },
    {
      text = "Cards you KEEP will go to your backbuffer",
      region = { {x = 0, y = 450, w = 900, h = 300},
                 {x = 0, y = 300, w = 300, h = 100},
                 {x = 700, y = 300, w = 250, h = 100} },
      text_pos = {x = 315, y = 320}
    },
    {
      text = "Cards you CONSUME will give you EXP",
      region = { {x = 0, y = 0, w = 900, h = 250},
                 {x = 0, y = 300, w = 300, h = 100},
                 {x = 700, y = 300, w = 250, h = 100} },
      text_pos = {x = 315, y = 355}
    },
    {
      text = "     How the EXP will distribute across your attributes\n"
          .. "will depend on which card type you been using the most",
      region = {x = 950, y = 200, w = 340, h = 300},
      text_pos = {x = 440, y = 380}
    },
    {
      text = "Hold D to confirm your selections",
      region = {{x = 0, y = 300, w = 300, h = 100}, {x = 700, y = 300, w = 250, h = 100}},
      text_pos = {x = 348, y = 338}
    },
  },
  altar = {
    {
      text = "You can activate such altars to consume a few cards",
      region = {x = 0, y = 0, w = VIEWDEFS.TILE_W, h = VIEWDEFS.TILE_H},
      text_pos = {x = 410, y = 110}
    },
  },
  use_stairs = {
    {
      text = "To interact with stairs or anything else, press D",
      region = {x = 410, y = 400, w = VIEWDEFS.TILE_W, h = VIEWDEFS.TILE_H},
      text_pos = {x = 410, y = 110}
    },
  },
}

local _font = FONT.get("Text", 25)
local _hint_data
local _cur_hint
local _bg_alpha
local _leaving

--[[ LOCAL FUNCTIONS ]]--

local stencilFunc

--[[ STATE FUNCTIONS ]]--

function state:enter(_, hint, region_position)
  _bg_alpha = 0
  _leaving = false
  PROFILE.setTutorial(hint, true)
  if not HINTS[hint] then
    error("Not a valid hint type: " .. tostring(hint))
  end
  _cur_hint = 1

  _hint_data = HINTS[hint]

  --Add specific region if given
  if region_position then
    local vec = CAMERA:relativeTileToScreen(unpack(region_position))
    HINTS[hint][_cur_hint].region.x = vec.x
    HINTS[hint][_cur_hint].region.y = vec.y
  end

  --Set visible var to each hint
  for _, hint_data in ipairs(_hint_data) do
    hint_data.visible = 0
  end
end

function state:leave()
  Util.destroyAll()
end

function state:update(dt)
  for i, hint in ipairs(_hint_data) do
    if _cur_hint == i then
      hint.visible = math.min(hint.visible + dt*HINT_SPEED, 1.0)
    elseif _bg_alpha >= 1.0 then
      hint.visible = math.max(hint.visible - dt*HINT_SPEED, 0.0)
    end
  end
  if not _leaving then
    _bg_alpha = math.min(_bg_alpha + dt*BG_SPEED, 1)
  elseif _hint_data[_cur_hint-1].visible <= 0.0 then
    _bg_alpha = math.max(_bg_alpha - dt*BG_SPEED, 0)
    if _bg_alpha <= 0 then
      SWITCHER:pop()
    end
  end
end

function state:keypressed()
  if _leaving or _bg_alpha < 1.0 or _hint_data[_cur_hint].visible < 1.0 then
    return
  end
  _cur_hint = _cur_hint + 1
  if not _hint_data[_cur_hint] then
    _leaving = true
  end
end

function state:draw()
  Draw.allTables()

  local g = love.graphics


  --Draw black filter
  g.stencil(stencilFunc, "replace", 1)
  g.setStencilTest("less", 1)
  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  g.setColor(0,0,0,.95*_bg_alpha)
  g.rectangle("fill", 0, 0, w, h)
  g.setStencilTest()

  --Draw text
  local c = COLORS.NEUTRAL
  for _, hint in ipairs(_hint_data) do
    g.setColor(c[1], c[2], c[3], hint.visible)
    _font:set()
    local pos = hint.text_pos
    g.print(hint.text, pos.x, pos.y)
  end

end

--Local functions

function stencilFunc()
    local g = love.graphics
    for _, hint in ipairs (_hint_data) do
      local r = hint.region
      --Multiple regions
      if r[1] and type(r[1]) == "table" then
        for _, region in ipairs(r) do
          local v = hint.visible
          g.rectangle("fill", region.x + (1-v)*region.w/2, region.y + (1-v)*region.h/2,
                      region.w*v, region.h*v)
        end
      --Only one region
      else
        local v = hint.visible
        g.rectangle("fill", r.x + (1-v)*r.w/2, r.y + (1-v)*r.h/2, r.w*v, r.h*v)
      end
    end
end

return state
