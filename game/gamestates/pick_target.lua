--MODULE FOR THE GAMESTATE: PICKING A TARGET--
local INPUT = require 'input'
local DIR = require 'domain.definitions.dir'

--STATE--
local state = {}

--LOCAL VARIABLES--

local _is_valid_position

local _sector_view
local _cursor

--LOCAL FUNCTIONS' FORWARD DECLARATION--
local _moveCursor
local _confirm
local _cancel

--STATE FUNCTIONS--

function state:enter(_, sector_view, target_opt)

  _sector_view = sector_view
  local i, j = unpack(target_opt.pos)
  _sector_view:newCursor(i, j, target_opt.aoe_hint, target_opt.validator,
                         target_opt.range_checker)

  _moveCursor = function (dir)
    _sector_view:moveCursor(unpack(DIR[dir]))
  end

  _confirm = function ()
    if _sector_view.cursor.validator(_sector_view:getCursorPos()) then
      local args = {
        target_is_valid = true,
        pos = {_sector_view:getCursorPos()}
      }
      SWITCHER.pop(args)
    end
  end

  _cancel = function ()
    local args = {
      target_is_valid = false,
    }
    SWITCHER.pop(args)
  end

end

function state:leave()
  _moveCursor = nil
  _confirm = nil
  _cancel = nil

  _sector_view:removeCursor()
end

function state:update(dt)
  if DEBUG then return end

  MAIN_TIMER:update(dt)
  _sector_view:lookAtCursor()

  for _,dir in ipairs(DIR) do
    if INPUT.wasActionPressed(dir:upper()) then
      return _moveCursor(dir)
    end
  end

  if INPUT.wasActionPressed('CONFIRM') then
    _confirm()
  elseif INPUT.wasActionPressed('CANCEL') then
    _cancel()
  end

end

function state:draw()

  Draw.allTables()

end

--Return state functions
return state

