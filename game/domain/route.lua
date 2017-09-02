
local Route = require 'lux.class' :new{}

local IDGenerator = require 'common.idgenerator'
local RANDOM = require 'common.random'
local PROFILE = require 'infra.profile'

local Body = require 'domain.body'
local Actor = require 'domain.actor'
local Sector = require 'domain.sector'

function Route:instance(obj)

  -- Saved data
  local _id
  local _id_generator = IDGenerator()
  local _player_name = "Unknown"
  local _player_id
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

    -- sectors
    _sectors = {}
    for _,sector_state in ipairs(state.sectors) do
      local sector = Sector(sector_state.specname)
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
    local id,sector = _register(Sector(sector_spec))
    sector:generate()
    table.insert(_sectors, sector)
    return id, sector
  end

  function obj.makeActor(bodyspec, actorspec, i, j)
    local bid, body = _register(Body(bodyspec))
    local aid, actor = _register(Actor(actorspec))
    actor:setBody(bid)
    _current_sector:putActor(actor, i, j)
    return actor
  end

  function obj.playTurns(...)
    local request, extra = _current_sector:playTurns(...)
    _controlled_actor = (request == "userTurn") and extra or nil
    return request
  end

  function obj.destroyAll()
    Util.destroySubtype("actor", "force")
    Util.destroySubtype("body", "force")
    Util.destroySubtype("sector", "force")
  end

end

return Route
