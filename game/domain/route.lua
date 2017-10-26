
local Route = require 'lux.class' :new{}

local IDGenerator = require 'common.idgenerator'
local RANDOM = require 'common.random'
local PROFILE = require 'infra.profile'

local Body = require 'domain.body'
local Actor = require 'domain.actor'
local Sector = require 'domain.sector'
local MOD = require 'domain.modifier'

function Route:instance(obj)

  -- Saved data
  local _id
  local _id_generator = IDGenerator()
  local _player_name = "Unknown"
  local _player_id
  local _modifiers = MOD
  local _sectors = {}
  local _current_sector = nil
  local _controlled_actor = nil

  Util.destroyAll 'true_force'

  local function _register(element)
    local id = element.id or _id_generator.newID()
    element:setId(id)
    element:setSubtype(element.spectype)
    return id, element
  end

  function obj.loadState(state)
    -- id
    _id = state.id
    _id_generator = IDGenerator(state.next_id)

    -- player
    _player_name = state.player_name
    _player_id = state.player_id

    -- rng
    -- setState is theoretically enough to reproduce seed as well
    RANDOM.setState(state.rng_state)

    _modifiers.loadState(state.modifiers)

    -- sectors
    _sectors = {}
    for _,sector_state in ipairs(state.sectors) do
      local sector = Sector(sector_state.specname, obj)
      sector:loadState(sector_state, _register)
      _register(sector)
      table.insert(_sectors, sector)
    end

    -- current sector
    obj.setCurrentSector(state.current_sector_id)
  end

  function obj.saveState()
    local state = {}
    -- id
    state.id = _id
    state.next_id = _id_generator.getNextID()
    -- id
    state.player_name = _player_name
    state.player_id = _player_id
    -- rng
    state.rng_state = RANDOM.getState()
    state.rng_seed = RANDOM.getSeed()
    -- modifiers
    state.modifiers = _modifiers.saveState()
    -- sectors
    state.sectors = {}
    for _,sector in ipairs(_sectors) do
      local sector_state = sector:saveState()
      table.insert(state.sectors, sector_state)
    end
    -- current sector
    state.current_sector_id = _current_sector.id
    return state
  end

  function obj.setCurrentSector(id)
    _current_sector = Util.findId(id)
  end

  function obj.getCurrentSector()
    return _current_sector
  end

  function obj.getControlledActor()
    return _controlled_actor
  end

  function obj.makeSector(sector_spec)
    local id,sector = _register(Sector(sector_spec, obj))
    sector:generate(_register)
    table.insert(_sectors, sector)
    return id, sector
  end

  --- Links an exit with the next sector over, generating it
  --  @param from_sector  The sector where to exit from
  --  @param idx          The exit index
  --  @param exit         The exit data
  function obj.linkSectorExit(from_sector, idx, exit)
    if not exit.id then
      local id, to_sector = obj.makeSector(exit.specname)
      local entry = to_sector:getExit(1)
      to_sector:link(1, from_sector.id, unpack(exit.pos))
      to_sector:setDepth(from_sector:getDepth() + 1)
      from_sector:link(idx, id, unpack(entry.pos))
    end
  end

  function obj.makeActor(bodyspec, actorspec, i, j)
    local bid, body = _register(Body(bodyspec))
    local aid, actor = _register(Actor(actorspec))
    actor:setBody(bid)
    _current_sector:putActor(actor, i, j)
    return actor
  end

  function obj.getPlayerActor()
    return Util.findId(_player_id)
  end

  function obj.takeExit()
  end

  local function _checkSector()
    local player_sector = obj.getPlayerActor():getBody():getSector()
    if player_sector ~= _current_sector then
      obj.setCurrentSector(player_sector.id)
    end
  end

  function obj.playTurns(...)
    _checkSector()
    local request, extra = _current_sector:playTurns(...)
    _controlled_actor = (request == "userTurn") and extra or nil
    return request, extra
  end

  function obj.destroyAll()
    Util.destroySubtype("actor", "force")
    Util.destroySubtype("body", "force")
    Util.destroySubtype("sector", "force")
  end

end

return Route
