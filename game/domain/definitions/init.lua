
local DEFS = {}

DEFS.NULL_METHOD = function() end
DEFS.DONE = "__DONE_VALUE__"
DEFS.DELETE = "__DELETE_VALUE__"
DEFS.CONSUME_EXP = 1
DEFS.MAX_PP = 100
DEFS.CARD_TYPES = {'ART', 'WIDGET', 'UPGRADE'}
DEFS.PRIMARY_ATTRIBUTES = {"COR", "ARC", "ANI"}
DEFS.ATTRIBUTES = {"COR", "ARC", "ANI", "SPD"}
DEFS.BODY_ATTRIBUTES = {"VIT", "DEF"}
DEFS.ALL_ATTRIBUTES = {"COR", "ARC", "ANI", "SPD", "VIT", "DEF", "FOV"}
DEFS.PACK_SIZE = 5
DEFS.HAND_LIMIT = 5
DEFS.TIME_UNIT = 20
DEFS.TIME_UNITS_PER_CHARGE = 1 * DEFS.TIME_UNIT

DEFS.ACTION       = require 'domain.definitions.action'
DEFS.TRIGGERS     = require 'domain.definitions.triggers'
DEFS.STASH_CARDS  = require 'domain.definitions.stash_cards'
DEFS.APT          = require 'domain.definitions.aptitude'

return DEFS
