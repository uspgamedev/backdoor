
local REGIONDEFS = require 'domain.definitions.regions'
local ZONES = REGIONDEFS.ZONES
local SYMBOLS = REGIONDEFS.SYMBOLS

local ROUTEMAP = {}

ROUTEMAP.initial_nodes = {
  { ZONES.A, "outpost" },
  { ZONES.A, SYMBOLS.O },
  { ZONES.A, SYMBOLS.O },
  { ZONES.A, SYMBOLS.O },
  --{ ZONES.A, SYMBOLS.O },
  --{ ZONES.A, SYMBOLS.O },
  { ZONES.B, SYMBOLS.V },
  { ZONES.B, SYMBOLS.V },
  { ZONES.B, SYMBOLS.V },
  --{ ZONES.B, SYMBOLS.V },
  --{ ZONES.B, SYMBOLS.V },
  --{ ZONES.C, SYMBOLS.V },
  --{ ZONES.C, SYMBOLS.V },
  --{ ZONES.C, SYMBOLS.V },
  --{ ZONES.C, SYMBOLS.V },
  --{ ZONES.C, SYMBOLS.V },
  { ZONES.D, SYMBOLS.v },
  { ZONES.D, SYMBOLS.v },
  { ZONES.D, SYMBOLS.v },
  --{ ZONES.D, SYMBOLS.v },
  --{ ZONES.D, SYMBOLS.v },
  --{ ZONES.E, SYMBOLS.v },
  --{ ZONES.E, SYMBOLS.v },
  --{ ZONES.E, SYMBOLS.v },
  --{ ZONES.E, SYMBOLS.v },
  --{ ZONES.E, SYMBOLS.v },
  { ZONES.F, SYMBOLS.e },
  --{ ZONES.G, SYMBOLS.e },
  --{ ZONES.H, SYMBOLS.e },
  --{ ZONES.I, SYMBOLS.e },
  --{ ZONES.J, SYMBOLS.e },
  --{ ZONES.K, SYMBOLS.e },
  --{ ZONES.L, SYMBOLS.e },
  --{ ZONES.M, SYMBOLS.e },
  { ZONES.A, "tutorial" },
}

ROUTEMAP.initial_connections = {
  {1, 2},
  {2, 3},
  {3, 4},
  {4, 5},
  {5, 6},
  {6, 7},
  {7, 8},
  {8, 9},
  {9, 10},
  {10, 11},
  {12, 1},
}

--ROUTEMAP.initial_connections = {
--  {1, 2},
--  {2, 3},
--  {2, 4},
--  {2, 5},
--  {2, 6},
--  {3, 4},
--  {4, 5},
--  {5, 6},
--  {6, 3},
--  -- connecting ruins to zones
--  {3, 7},
--  {4, 12},
--  {5, 17},
--  {6, 22},
--  -- building zone 1
--  {7, 8},
--  {7, 9},
--  {8, 10},
--  {9, 11},
--  {10, 11},
--  -- connect zone 1 to zone 2
--  {9, 13},
--  -- building zone 2
--  {12, 13},
--  {12, 14},
--  {13, 15},
--  {14, 16},
--  {15, 16},
--  -- connect zone 2 to zone 3
--  {14, 18},
--  -- building zone 3
--  {17, 18},
--  {17, 19},
--  {18, 20},
--  {19, 21},
--  {20, 21},
--  -- connect zone 3 to zone 4
--  {19, 23},
--  -- building zone 4
--  {22, 23},
--  {22, 24},
--  {23, 25},
--  {24, 26},
--  {25, 26},
--  -- connect zone 4 to zone 1
--  {24, 8},
--  -- connect zones to seed regions
--  {10, 27},
--  {11, 28},
--  {15, 29},
--  {16, 30},
--  {20, 31},
--  {21, 32},
--  {25, 33},
--  {26, 34},
--}

return ROUTEMAP

