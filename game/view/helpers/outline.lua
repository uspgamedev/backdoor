--[[
This is a modified version of pedro gimeno's outline shader code.
Below is the original license for it:

(C) Copyright 2018 Pedro Gimeno Fortea

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


Usage:

local outline_only = false -- draw the outline AND the image in the same pass
--local outline_only = true -- draw the outline only

-- 'require' returns a constructor that requires the outline_only parameter
local outliner = require 'outliner'(outline_only)

-- sets the outline colour (in 0..1 range)
outliner:outline(r, g, b)

-- draws an outline or an image with outline (decided at construction time),
-- possibly using a quad. Same parameters as love.graphics.draw except for the
-- size prefix, which is the size of the outline.
outliner:draw(size, img, ...)

]]
local aux = {0, 0, 0, 0}
local lgdraw = love.graphics.draw
local lgsetShader = love.graphics.setShader

local function color(self, r, g, b)
  aux[1] = r
  aux[2] = g
  aux[3] = b
  aux[4] = nil
  self.shader:send("outline", aux)
end

local function predraw(self, size, img, ...)
  local quad = (...)
  if type(quad) == "userdata" then
    -- assumed quad
    local sx, sy = quad:getTextureDimensions()
    aux[1], aux[2], aux[3], aux[4] = quad:getViewport()
    aux[1] = aux[1] / sx
    aux[2] = aux[2] / sy
    aux[3] = aux[3] / sx
    aux[4] = aux[4] / sy
    self.shader:send("quad", aux)
    aux[1] = size / sx
    aux[2] = size / sy
  else
    local sx, sy = img:getDimensions()
    aux[1], aux[2], aux[3], aux[4] = 0, 0, 1, 1
    self.shader:send("quad", aux)
    aux[1] = size / sx
    aux[2] = size / sy
  end
  aux[3], aux[4] = nil, nil
  self.shader:send("stepSize", aux)
  lgsetShader(self.shader)
end


local function new_outliner(outline_only)
  local shader = [[

// This parameter affects the roundness. 0.75 is close to the Euclidean
// correct value. If it's 0.0, the shape of the "brush" making the outline
// will be a diamond; if it's 1.0, it will be a square.
const float t = 0.75;

extern vec3 outline; // Outline R,G,B
extern vec2 stepSize; // Distance parameter
extern vec4 quad;

const vec4 zero = vec4(0.,0.,0.,0.);
vec2 q1 = quad.xy;
vec2 q2 = quad.xy + quad.zw;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{

  // get color of pixels:
  float alpha = -20.0 * texture2D(texture, clamp(texturePos, q1, q2)).a;
  vec2 aux = vec2(stepSize.x, 0.);
  alpha += texture2D(texture, clamp(texturePos + aux, q1, q2) ).a;
  alpha += texture2D(texture, clamp(texturePos - aux, q1, q2) ).a;
  aux = vec2(0., stepSize.y);
  alpha += texture2D(texture, clamp(texturePos + aux, q1, q2) ).a;
  alpha += texture2D(texture, clamp(texturePos - aux, q1, q2) ).a;

  if (t != 0.0)
  {
    aux = stepSize;
    alpha += t * texture2D(texture, clamp(texturePos + aux, q1, q2)).a;
    alpha += t * texture2D(texture, clamp(texturePos - aux, q1, q2)).a;
    aux = vec2(-stepSize.x, stepSize.y);
    alpha += t * texture2D(texture, clamp(texturePos + aux, q1, q2)).a;
    alpha += t * texture2D(texture, clamp(texturePos - aux, q1, q2)).a;
  }

@calc_result@
  return result;
}
  ]]


  if outline_only then
    shader = shader:gsub("@calc_result@", [[
  vec4 result = vec4(outline, alpha);
]])
  else
    shader = shader:gsub("@calc_result@", [[
  vec4 result =
      max(max(sign(alpha), 0.) * vec4( outline, alpha ), zero)
    - min(min(sign(alpha), 0.) * texture2D(texture, texturePos), zero);
]])
  end
  shader = love.graphics.newShader(shader)

  local result = {
    shader = shader;
    predraw = predraw;
    color = color;
  }

  return result
end

return new_outliner
