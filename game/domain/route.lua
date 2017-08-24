
local Route = require 'lux.class' :new{}

local IDGenerator = require 'common.idgenerator'

local Body = require 'domain.body'
local Actor = require 'domain.actor'
local Sector = require 'domain.sector'

function Route:instance(obj)

  local _id_generator = IDGenerator()
  local _current_sector = nil
  local _controlled_actor = nil

  Util.destroyAll 'true_force'

  local function _register(element)
    local id = _id_generator.newID()
    element:setId(id)
    element:setSubtype(element.spectype)
    return id, element
  end

  function obj.loadState(state)
    _id_generator = IDGenerator(state.next_id)
  end

  function obj.saveState()
    local state = {}
    state.next_id = _id_generator.getNextID()
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
    _controlled_actor = _current_sector:playTurns(...)
  end

end

return Route

