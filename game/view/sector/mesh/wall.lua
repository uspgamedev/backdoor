
local VIEWDEFS    = require 'view.definitions'
local vec2        = require 'cpml' .vec2

local _WALL_H = 80
local _QUADFACES = {1, 2, 3, 2, 4, 3}

local WallMesh = require 'lux.prototype' :new {}

WallMesh.__init = {
  pos = vec2(),
  count = 0,
  vertices = {},
  faces = {},
  border_color = {.5, .5, .5, 1}
}

local function _appendVertices(mesh, color, ...)
  local vtx_seq = { ... }
  for _,vtx in ipairs(vtx_seq) do
    mesh.count = mesh.count + 1
    mesh.vertices[mesh.count] = { vtx.x, vtx.y, 0, 0, unpack(color) }
  end
end

local function _appendFace(mesh, base)
  local n = #mesh.faces
  for i,idx in ipairs(_QUADFACES) do
    mesh.faces[n+i] = base + idx
  end
end
  
local function _appendQuad(mesh, color, v1, v2, v3, v4)
  local base = mesh.count
  local pos = mesh.pos
  _appendVertices(mesh, color, pos+v1, pos+v2, pos+v3, pos+v4)
  _appendFace(mesh, base)
end

function WallMesh:map()
  return ipairs(self.faces)
end

function WallMesh:getVertex(i)
  return { unpack(self.vertices[i]) }
end

function WallMesh:addSide(color, v1, v2, b1, b2)
  local height = vec2(0,-1)*_WALL_H
  if color then
    _appendQuad(self, color, v1 + height, v2 + height, v1, v2)
  end
  b2 = b2 or b1
  if b1 then
    _appendQuad(self, self.border_color, v1 + height + b1, v2 + height + b2,
                                         v1 + height, v2 + height)
  end
end

return WallMesh

