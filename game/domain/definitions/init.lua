
local DEFS = {}

DEFS.DONE = "__DONE_VALUE__"
DEFS.DELETE = "__DELETE_VALUE__"
DEFS.CONSUME_EXP = 1
DEFS.PRIMARY_ATTRIBUTES = {"ATH", "ARC", "MEC"}
DEFS.ATTRIBUTES = {"ATH", "ARC", "MEC", "SPD"}
DEFS.BODY_ATTRIBUTES = {"HP", "DEF"}
DEFS.WIDGETS = {
  "WIDGET_A",
  "WIDGET_B",
  "WIDGET_C",
  "WIDGET_D",
}
DEFS.ACTOR_BUFFER_NUM = 3
DEFS.PACK_SIZE = 10
DEFS.TIME_UNIT = 10
DEFS.TIME_UNITS_PER_CHARGE = 1 * DEFS.TIME_UNIT

return DEFS

