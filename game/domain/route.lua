
local Route = require 'lux.class' :new{}

local IDGenerator = require 'common.idgenerator'
local RANDOM = require 'common.random'
local PROFILE = require 'infra.profile'

local Body = require 'domain.body'
local Actor = require 'domain.actor'
local Sector = require 'domain.sector'

function Route:instance(obj)

  local _id_generator = IDGenerator()
  local _current_sector = nil
  local _controlled_actor = nil
  local _data

  Util.destroyAll 'true_force'

  local function _register(element)
    local id = _id_generator.newID()
    element:setId(id)
    element:setSubtype(element.spectype)
    return id, element
  end

  function obj.loadState(state)
    _data = state
    _id_generator = IDGenerator(_data.next_id)
  end

  function obj.saveState()
    _data.next_id = _id_generator.getNextID()
    _data.rng_state = RANDOM.getState()
    PROFILE.saveRoute(_data)
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
    _current_sector = sector
    return sector
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
    _controlled_actor = (request == "actorTurn") and extra or nil
    return request
  end

  function obj.destroyAll()
    Util.destroySubtype("actor", "force")
    Util.destroySubtype("body", "force")
    Util.destroySubtype("sector", "force")
  end

end

return Route

