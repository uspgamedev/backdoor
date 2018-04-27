
local REGIONDEFS = {}


-- Node Zones

REGIONDEFS.ZONES = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  A = 'A',
  B = 'B',
  C = 'C',
  D = 'D',
  E = 'E',
  F = 'F',
  G = 'G',
  H = 'H',
  I = 'I',
  J = 'J',
  K = 'K',
  L = 'L',
  M = 'M',
}


-- Node Symbols

REGIONDEFS.SYMBOLS = {
  'O', 'V', 'v', 'e',
  O = 'sector01',
  V = 'sector02',
  v = 'sector03',
  e = 'sector_final',
}


-- Subgraph Rules

REGIONDEFS.RULES = {
  {
    pattern = {
      v = {'(.):O', '(.):O'},
      e = { {1,2} },
    },
    result = {
      v = {'%1:V', '%1:V', '%2:v'},
      e = { {1,2}, {1,3}, {2,3}, },
    },
  },
}

return REGIONDEFS

