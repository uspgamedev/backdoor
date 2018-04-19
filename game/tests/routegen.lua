
-- Graph Type

local Graph = require 'common.graph'

-- Graph Node Zones

local _ZONE = {
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

-- Graph Node Symbols

local _SYMB = {
  'O', 'V', 'v', 'e',
  O = 'O',
  V = 'V',
  v = 'v',
  e = 'e',
}

local RULES = {
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

local function _getMatches(graph, node_idx, pattern, mapping, matches)
  matches = matches or {}
  mapping = mapping or 1
  --
end

local function _applyRule(graph, rule_idx)
  local rule = RULES[rule_idx]
  local pattern = rule.pattern
  local result = rule.result
  local matches = {}
  for node_idx, node in graph.eachNode() do
    for _,match in ipairs(_getMatches(graph, node_idx, pattern)) do
      table.insert(matches, match)
    end
  end
end

--[[--

A match is, per node:

1. Has greater than or equal to number of edges of pattern
2. Has matching connection types with pattern (node-type1, node-type2)

--]]--

return function()
  local route_map = Graph()
  do
    local r_0 = route_map.addNode(_ZONE.A, _SYMB.O)
    local r_1 = route_map.addNode(_ZONE.A, _SYMB.O)
    local r_2 = route_map.addNode(_ZONE.A, _SYMB.O)
    local r_3 = route_map.addNode(_ZONE.A, _SYMB.O)
    local r_4 = route_map.addNode(_ZONE.A, _SYMB.O)
    local z1_1 = route_map.addNode(_ZONE.B, _SYMB.O)
    local z1_2 = route_map.addNode(_ZONE.B, _SYMB.O)
    local z1_3 = route_map.addNode(_ZONE.B, _SYMB.O)
    local z1_4 = route_map.addNode(_ZONE.B, _SYMB.O)
    local z1_5 = route_map.addNode(_ZONE.B, _SYMB.O)
    local z2_1 = route_map.addNode(_ZONE.C, _SYMB.O)
    local z2_2 = route_map.addNode(_ZONE.C, _SYMB.O)
    local z2_3 = route_map.addNode(_ZONE.C, _SYMB.O)
    local z2_4 = route_map.addNode(_ZONE.C, _SYMB.O)
    local z2_5 = route_map.addNode(_ZONE.C, _SYMB.O)
    local z3_1 = route_map.addNode(_ZONE.D, _SYMB.O)
    local z3_2 = route_map.addNode(_ZONE.D, _SYMB.O)
    local z3_3 = route_map.addNode(_ZONE.D, _SYMB.O)
    local z3_4 = route_map.addNode(_ZONE.D, _SYMB.O)
    local z3_5 = route_map.addNode(_ZONE.D, _SYMB.O)
    local z4_1 = route_map.addNode(_ZONE.E, _SYMB.O)
    local z4_2 = route_map.addNode(_ZONE.E, _SYMB.O)
    local z4_3 = route_map.addNode(_ZONE.E, _SYMB.O)
    local z4_4 = route_map.addNode(_ZONE.E, _SYMB.O)
    local z4_5 = route_map.addNode(_ZONE.E, _SYMB.O)
    local s1 = route_map.addNode(_ZONE.F, _SYMB.O)
    local s2 = route_map.addNode(_ZONE.G, _SYMB.O)
    local s3 = route_map.addNode(_ZONE.H, _SYMB.O)
    local s4 = route_map.addNode(_ZONE.I, _SYMB.O)
    local s5 = route_map.addNode(_ZONE.J, _SYMB.O)
    local s6 = route_map.addNode(_ZONE.K, _SYMB.O)
    local s7 = route_map.addNode(_ZONE.L, _SYMB.O)
    local s8 = route_map.addNode(_ZONE.M, _SYMB.O)

    route_map.connect(r_0, r_1)
    route_map.connect(r_0, r_2)
    route_map.connect(r_0, r_3)
    route_map.connect(r_0, r_4)
    route_map.connect(r_1, r_2)
    route_map.connect(r_2, r_3)
    route_map.connect(r_3, r_4)
    route_map.connect(r_4, r_1)

    route_map.connect(r_1, z1_1)
    route_map.connect(r_2, z2_1)
    route_map.connect(r_3, z3_1)
    route_map.connect(r_4, z4_1)

    route_map.connect(z1_1, z1_2)
    route_map.connect(z1_1, z1_3)
    route_map.connect(z1_2, z1_4)
    route_map.connect(z1_3, z1_5)
    route_map.connect(z1_4, z1_5)

    route_map.connect(z1_3, z2_2)

    route_map.connect(z2_1, z2_2)
    route_map.connect(z2_1, z2_3)
    route_map.connect(z2_2, z2_4)
    route_map.connect(z2_3, z2_5)
    route_map.connect(z2_4, z2_5)

    route_map.connect(z2_3, z3_2)

    route_map.connect(z3_1, z3_2)
    route_map.connect(z3_1, z3_3)
    route_map.connect(z3_2, z3_4)
    route_map.connect(z3_3, z3_5)
    route_map.connect(z3_4, z3_5)

    route_map.connect(z3_3, z4_2)

    route_map.connect(z4_1, z4_2)
    route_map.connect(z4_1, z4_3)
    route_map.connect(z4_2, z4_4)
    route_map.connect(z4_3, z4_5)
    route_map.connect(z4_4, z4_5)

    route_map.connect(z4_3, z1_2)

    route_map.connect(z1_4, s1)
    route_map.connect(z1_5, s2)
    route_map.connect(z2_4, s3)
    route_map.connect(z2_5, s4)
    route_map.connect(z3_4, s5)
    route_map.connect(z3_5, s6)
    route_map.connect(z4_4, s7)
    route_map.connect(z4_5, s8)
  end

end

