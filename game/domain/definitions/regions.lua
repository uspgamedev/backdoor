
local REGIONDEFS = {}


-- Node Zones

REGIONDEFS.ZONES = {
  A = 'ruins',
  B = 'zone1',
  C = 'zone2',
  D = 'zone3',
  E = 'zone4',
  F = 'seed1',
  G = 'seed2',
  H = 'seed3',
  I = 'seed4',
  J = 'seed5',
  K = 'seed6',
  L = 'seed7',
  M = 'seed8',
}


-- Node Symbols

REGIONDEFS.SYMBOLS = {
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

