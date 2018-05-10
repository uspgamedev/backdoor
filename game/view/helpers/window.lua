
local g = love.graphics
local _GAUSSIAN = g.newShader([=[

extern vec2 tex_size;
const int range = 5;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords) {
  vec2 pixel_size = 1.0 / tex_size;
  float alpha = 0.0;
  float ponder = 0.0;
  for (int i = -range; i < range; i++) {
    for (int j = -range; j < range; j++) {
      float weight = -(distance(vec2(j, i), vec2(0.0, 0.0)) - 2.0 * range);
      alpha += weight * (Texel(tex, uv + vec2(j, i) * pixel_size)).w;
      ponder += weight;
    }
  }
  alpha = alpha / ponder;
  return vec4(1, 1, 1, alpha) * color;
}

]=])

local _MG = 16
local _SLANT = 32

local _window_cache = {}

local function _getWindowName(width, height)
  return width + 10*height
end


local function _createWindow(width, height)
  local canvas = g.newCanvas(width + _MG * 4, height + _MG * 4)
  local polygon = {
    0, 0,
    width - _SLANT, 0,
    width, _SLANT,
    width, height,
    _SLANT, height,
    0, height - _SLANT,
  }
  local box
  local hard
  local glow


  -- box texture
  g.setCanvas(canvas)
  g.clear()
  g.push()
  g.translate(_MG, _MG)
  g.setBackgroundColor(0, 0, 0, 0)
  g.setLineWidth(_MG)
  g.setColor(1, 1, 1)
  g.polygon("fill", polygon)
  g.setCanvas()
  g.pop()
  box = g.newImage(canvas:newImageData())

  -- hard texture
  g.setCanvas(canvas)
  g.clear()
  g.push()
  g.translate(_MG, _MG)
  g.setLineWidth(4)
  g.setColor(1, 1, 1)
  g.polygon("line", polygon)
  g.setCanvas()
  g.pop()
  hard = g.newImage(canvas:newImageData())

  -- soft texture
  g.setCanvas(canvas)
  g.clear()
  g.push()
  g.translate(_MG, _MG)
  g.setLineWidth(16)
  g.setColor(1, 1, 1)
  g.polygon("line", polygon)
  g.setCanvas()
  g.pop()
  soft = g.newImage(canvas:newImageData())

  -- create texture
  g.setCanvas(canvas)
  g.clear()
  _GAUSSIAN:send("tex_size", {width, height})
  g.setShader(_GAUSSIAN)
  g.setColor(0.1, 0.1, 0.8, 0.333)
  g.draw(box, 0, 0)
  g.setShader()
  g.setColor(1, 1, 1, 1)
  g.draw(hard, 0, 0)
  _GAUSSIAN:send("tex_size", {width, height})
  g.setShader(_GAUSSIAN)
  g.setColor(1, 1, 1, 0.5)
  g.draw(soft, 0, 0)
  g.setShader()
  g.setCanvas()
  return g.newImage(canvas:newImageData())
end

local WINDOW = {}

function WINDOW.getTexture(width, height)
  local windowname =_getWindowName(width, height)
  if not _window_cache[windowname] then
    _window_cache[windowname] = _createWindow(width, height)
  end
  return _window_cache[windowname]
end

return WINDOW

