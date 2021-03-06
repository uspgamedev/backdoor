
local DEFS = {}

DEFS.NULL_METHOD = function() end
DEFS.DONE = "__DONE_VALUE__"
DEFS.DELETE = "__DELETE_VALUE__"
DEFS.CONSUME_EXP = 5
DEFS.MAX_PP = 6
DEFS.CARD_TYPES = { 'ART', 'WIDGET' }
DEFS.PRIMARY_ATTRIBUTES = {
  "COR", "ARC", "ANI",
  COR = "COR",
  ARC = "ARC",
  ANI = "ANI",
}
DEFS.ALL_ATTRIBUTES = {
  "COR", "ARC", "ANI",
  "FOV",
  "SKL", "SPD", "VIT",
}
DEFS.CARD_ATTRIBUTES = {
  "COR", "ARC", "ANI", "NONE",
  COR = "COR",
  ARC = "ARC",
  ANI = "ANI",
  NONE = "NONE",
}

DEFS.HAND_LIMIT = 5
DEFS.PACK_SIZE  = 3

DEFS.ACTION       = require 'domain.definitions.action'
DEFS.TRIGGERS     = require 'domain.definitions.triggers'
DEFS.APT          = require 'domain.definitions.aptitude'
DEFS.ATTR         = require 'domain.definitions.attribute'
DEFS.STATUS_TAGS  = require 'domain.definitions.status_tags'

return DEFS
