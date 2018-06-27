
local DEFS = {}

DEFS.NULL_METHOD = function() end
DEFS.DONE = "__DONE_VALUE__"
DEFS.DELETE = "__DELETE_VALUE__"
DEFS.CONSUME_EXP = 10
DEFS.MAX_PP = 100
DEFS.CARD_TYPES = { 'ART', 'WIDGET' }
DEFS.PRIMARY_ATTRIBUTES = {
  "COR", "ARC", "ANI",
  COR = "COR",
  ARC = "ARC",
  ANI = "ANI",
}
DEFS.ALL_ATTRIBUTES = {
  "COR", "ARC", "ANI",
  "SPD", "FOV",
  "DEF", "EFC", "VIT",
  "RES", "FIN", "CON"
}
DEFS.BODY_ATTRIBUTES = {
  "DEF", "EFC", "VIT",
  "RES", "FIN", "CON"
}
DEFS.CARD_ATTRIBUTES = {
  "COR", "ARC", "ANI", "NONE"
}
DEFS.PACK_SIZE = 5
DEFS.HAND_LIMIT = 5

DEFS.ACTION       = require 'domain.definitions.action'
DEFS.TRIGGERS     = require 'domain.definitions.triggers'
DEFS.STASH_CARDS  = require 'domain.definitions.stash_cards'
DEFS.APT          = require 'domain.definitions.aptitude'
DEFS.ATTR         = require 'domain.definitions.attribute'
DEFS.STATUS_TAGS  = require 'domain.definitions.status_tags'

return DEFS
