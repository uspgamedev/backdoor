
local REGIONDEFS = require 'domain.definitions.regions'

local DATA = {}

DATA.route_names = {
  "Banana",
  "Kiwi",
  "Omar",
  "Orange",
  "Front Door",
  "Longsword",
  "Jennifer",
  "Evil Dragon",
  "Jacekt",
  "Pants",
  "Green",
  "Boots",
  "Pudding",
  "Cake",
  "Fox",
  "OwO",
  "Nope",
  "Hector",
  "Black",
  "Glass",
  "January",
  "Hallow",
  "Hollow",
  "Skeleton",
  "Ghost",
  "Sord",
  "Juniper",
  "Corgi",
  "Dog",
  "Cat"
}

DATA.initial_sector_tiles = [=[
.....
.....
..>..
.....
.....
 ...
 ...
 ...
 .e.
 ...
]=]

local route_map = require 'common.graph' ()
do
  local ZONES = REGIONDEFS.ZONES
  local SYMBOLS = REGIONDEFS.ZONES
  local r_0 = route_map.addNode(ZONES.A, SYMBOLS.O)
  local r_1 = route_map.addNode(ZONES.A, SYMBOLS.O)
  local r_2 = route_map.addNode(ZONES.A, SYMBOLS.O)
  local r_3 = route_map.addNode(ZONES.A, SYMBOLS.O)
  local r_4 = route_map.addNode(ZONES.A, SYMBOLS.O)
  local z1_1 = route_map.addNode(ZONES.B, SYMBOLS.O)
  local z1_2 = route_map.addNode(ZONES.B, SYMBOLS.O)
  local z1_3 = route_map.addNode(ZONES.B, SYMBOLS.O)
  local z1_4 = route_map.addNode(ZONES.B, SYMBOLS.O)
  local z1_5 = route_map.addNode(ZONES.B, SYMBOLS.O)
  local z2_1 = route_map.addNode(ZONES.C, SYMBOLS.O)
  local z2_2 = route_map.addNode(ZONES.C, SYMBOLS.O)
  local z2_3 = route_map.addNode(ZONES.C, SYMBOLS.O)
  local z2_4 = route_map.addNode(ZONES.C, SYMBOLS.O)
  local z2_5 = route_map.addNode(ZONES.C, SYMBOLS.O)
  local z3_1 = route_map.addNode(ZONES.D, SYMBOLS.O)
  local z3_2 = route_map.addNode(ZONES.D, SYMBOLS.O)
  local z3_3 = route_map.addNode(ZONES.D, SYMBOLS.O)
  local z3_4 = route_map.addNode(ZONES.D, SYMBOLS.O)
  local z3_5 = route_map.addNode(ZONES.D, SYMBOLS.O)
  local z4_1 = route_map.addNode(ZONES.E, SYMBOLS.O)
  local z4_2 = route_map.addNode(ZONES.E, SYMBOLS.O)
  local z4_3 = route_map.addNode(ZONES.E, SYMBOLS.O)
  local z4_4 = route_map.addNode(ZONES.E, SYMBOLS.O)
  local z4_5 = route_map.addNode(ZONES.E, SYMBOLS.O)
  local s1 = route_map.addNode(ZONES.F, SYMBOLS.O)
  local s2 = route_map.addNode(ZONES.G, SYMBOLS.O)
  local s3 = route_map.addNode(ZONES.H, SYMBOLS.O)
  local s4 = route_map.addNode(ZONES.I, SYMBOLS.O)
  local s5 = route_map.addNode(ZONES.J, SYMBOLS.O)
  local s6 = route_map.addNode(ZONES.K, SYMBOLS.O)
  local s7 = route_map.addNode(ZONES.L, SYMBOLS.O)
  local s8 = route_map.addNode(ZONES.M, SYMBOLS.O)
  -- building ruins
  route_map.connect(r_0, r_1)
  route_map.connect(r_0, r_2)
  route_map.connect(r_0, r_3)
  route_map.connect(r_0, r_4)
  route_map.connect(r_1, r_2)
  route_map.connect(r_2, r_3)
  route_map.connect(r_3, r_4)
  route_map.connect(r_4, r_1)
  -- connecting ruins to zones
  route_map.connect(r_1, z1_1)
  route_map.connect(r_2, z2_1)
  route_map.connect(r_3, z3_1)
  route_map.connect(r_4, z4_1)
  -- building zone 1
  route_map.connect(z1_1, z1_2)
  route_map.connect(z1_1, z1_3)
  route_map.connect(z1_2, z1_4)
  route_map.connect(z1_3, z1_5)
  route_map.connect(z1_4, z1_5)
  -- connect zone 1 to zone 2
  route_map.connect(z1_3, z2_2)
  -- building zone 2
  route_map.connect(z2_1, z2_2)
  route_map.connect(z2_1, z2_3)
  route_map.connect(z2_2, z2_4)
  route_map.connect(z2_3, z2_5)
  route_map.connect(z2_4, z2_5)
  -- connect zone 2 to zone 3
  route_map.connect(z2_3, z3_2)
  -- building zone 3
  route_map.connect(z3_1, z3_2)
  route_map.connect(z3_1, z3_3)
  route_map.connect(z3_2, z3_4)
  route_map.connect(z3_3, z3_5)
  route_map.connect(z3_4, z3_5)
  -- connect zone 3 to zone 4
  route_map.connect(z3_3, z4_2)
  -- building zone 4
  route_map.connect(z4_1, z4_2)
  route_map.connect(z4_1, z4_3)
  route_map.connect(z4_2, z4_4)
  route_map.connect(z4_3, z4_5)
  route_map.connect(z4_4, z4_5)
  -- connect zone 4 to zone 1
  route_map.connect(z4_3, z1_2)
  -- connect zones to seed regions
  route_map.connect(z1_4, s1)
  route_map.connect(z1_5, s2)
  route_map.connect(z2_4, s3)
  route_map.connect(z2_5, s4)
  route_map.connect(z3_4, s5)
  route_map.connect(z3_5, s6)
  route_map.connect(z4_4, s7)
  route_map.connect(z4_5, s8)
end

DATA.route_map = route_map


return DATA

