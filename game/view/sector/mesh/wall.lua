
local COLORS      = require 'domain.definitions.colors'
local vec3        = require 'cpml' .vec3

local _WALL_H = 80
local _QUADFACES = {1, 2, 3, 2, 4, 3}

local WallMesh = require 'lux.prototype' :new {}

WallMesh.__init = {
  pos = vec3(),
  count = 0,
  vertices = {},
  faces = {},
  border_color = {.5, .5, .5, 1}
}

local function _tov3(v)
  return vec3(v.x, v.y, 0)
end

local function _appendVertices(mesh, color, ...)
  local vtx_seq = { ... }
  for _,vtx in ipairs(vtx_seq) do
    mesh.count = mesh.count + 1
    mesh.vertices[mesh.count] = { vtx.x, vtx.y, vtx.z, unpack(color) }
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
  local pos = _tov3(mesh.pos)
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
  local height = vec3(0,0,-1)*_WALL_H
  b2 = b2 or b1
  v1, v2, b1, b2 = _tov3(v1), _tov3(v2), _tov3(b1), _tov3(b2)
  if color then
    _appendQuad(self, color, v1 + height, v2 + height, v1, v2)
  end
  if b1 then
    _appendQuad(self, self.border_color, v1 + height + b1, v2 + height + b2,
                                         v1 + height, v2 + height)
  end
end

function WallMesh:addBottom(v1, v2, v3, v4, extra, ...)
  v1, v2, v3, v4 = _tov3(v1), _tov3(v2), _tov3(v3), _tov3(v4 or v3)
  _appendQuad(self, COLORS.BLACK, v1, v2, v3, v4)
  if extra then
    return self:addBottom(v3, v4, extra, ...)
  end
end

function WallMesh:addTop(color, v1, v2, v3, v4, extra, ...)
  local height = vec3(0,0,-1)*_WALL_H
  v1, v2, v3, v4 = _tov3(v1), _tov3(v2), _tov3(v3), _tov3(v4 or v3)
  _appendQuad(self, color, v1 + height, v2 + height, v3 + height,
              v4 + height)
  if extra then
    return self:addTop(color, v3, v4, extra, ...)
  end
end

return WallMesh

