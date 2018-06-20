
local Route = require 'lux.class' :new{}

local IDGenerator = require 'common.idgenerator'
local RANDOM = require 'common.random'
local PROFILE = require 'infra.profile'

local BUILDERS = require 'lux.pack' 'domain.builders'
local PACK = require 'domain.pack'
local Body = require 'domain.body'
local Actor = require 'domain.actor'
local Sector = require 'domain.sector'
local Behaviors = require 'domain.behaviors'

function Route:instance(obj)

  -- Saved data
  local _id
  local _id_generator = IDGenerator()
  local _player_name = "Unknown"
  local _player_id
  local _sectors = {}
  local _behaviors = Behaviors()
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
      local sector = Sector(sector_state.specname, obj)
      sector:loadState(sector_state, _register)
      _register(sector)
      table.insert(_sectors, sector)
    end

    -- behaviors
    _behaviors.load(state.behaviors)

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
    -- behaviors
    state.behaviors = _behaviors.save()
    -- current sector
    state.current_sector_id = _current_sector.id
    return state
  end

  function obj.getPlayerName()
    return _player_name
  end

  function obj.getBehaviors()
    return _behaviors
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

  --- Links an exit with the next sector over, generating it
  --  @param from_sector  The sector where to exit from
  --  @param idx          The exit index
  --  @param exit         The exit data
  function obj.linkSectorExit(from_sector, target_sector_id, exit)
    if not exit.target_pos then
      local to_sector = Util.findId(target_sector_id)
      if not to_sector:isGenerated() then
        to_sector:generate()
      end
      local entry = to_sector:getExit(from_sector.id)
      to_sector:link(from_sector.id, unpack(exit.pos))
      from_sector:link(target_sector_id, unpack(entry.pos))
    end
  end

  function obj.makeCard(cardspec)
    local card = BUILDERS.card.buildElement(_id_generator, cardspec)
    _register(card)
    return card
  end

  function obj.makePack(collection)
    local speclist = PACK.generatePackFrom(collection)
    local pack = {}
    for i,cardspec in ipairs(speclist) do
      pack[i] = obj.makeCard(cardspec)
    end
    return pack
  end

  function obj.makeBody(sector, bodyspec, i, j)
    local body = BUILDERS.body.buildElement(_id_generator, bodyspec, i, j)
    _register(body)
    sector:putBody(body, i, j)
    return body
  end

  function obj.makeActor(sector, actorspec, bodyspec, i, j)
    local b_state = BUILDERS.body.buildState(_id_generator, bodyspec, i, j)
    local actor = BUILDERS.actor.buildElement(_id_generator, actorspec, b_state)
    local body = Body(bodyspec)
    body:loadState(b_state)
    _register(actor)
    _register(body)
    sector:putActor(actor, i, j)
    return actor, body
  end

  function obj.getPlayerActor()
    return Util.findId(_player_id)
  end

  function obj.checkSector()
    local player_sector = obj.getPlayerActor():getBody():getSector()
    if player_sector ~= _current_sector then
      obj.setCurrentSector(player_sector.id)
      return true
    end
    return false
  end

  function obj.playTurns(...)
    local request, extra = _current_sector:playTurns(...)
    if request == 'userTurn' then
      _controlled_actor = extra
    end
    return request, extra
  end

  function obj.destroyAll()
    Util.destroySubtype("actor", "force")
    Util.destroySubtype("body", "force")
    Util.destroySubtype("sector", "force")
  end

end

return Route
