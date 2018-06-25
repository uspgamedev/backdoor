
local INPUT        = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DIR          = require 'domain.definitions.dir'
local PLAYSFX      = require 'helpers.playsfx'
local CardInfo     = require 'view.cardinfo'
local vec2         = require 'cpml' .vec2

local state = {}

local _sector_view
local _card_info_view
local _current_dir
local _body_block
local _card

local function _updateDir(dir)
  _current_dir = DIR[dir]
  _sector_view:setRayDir(_current_dir, _body_block)
end

function state:enter(prev, sector_view, body_block, card)
  _sector_view = sector_view
  _body_block = body_block
  if card then
    _card_info_view = CardInfo()
    _card_info_view:addElement('HUD')
    _card_info_view:set(card)
  end
  _updateDir(DIR[1])
end

function state:leave()
  if _card_info_view then
    _card_info_view:destroy()
    _card_info_view = nil
  end
end

function state:update(dt)
  MAIN_TIMER:update(dt)

  if INPUT.wasActionPressed('CONFIRM') then
    _sector_view:setRayDir()
    SWITCHER.pop(_current_dir)
  elseif INPUT.wasActionPressed('CANCEL') then
    _sector_view:setRayDir()
    PLAYSFX 'back-menu'
    SWITCHER.pop()
  else
    for _,dir in ipairs(DIR) do
      if DIRECTIONALS.wasDirectionTriggered(dir) then
        _updateDir(dir)
      end
    end
  end
end

function state:draw()
  Draw.allTables()
end

return state

