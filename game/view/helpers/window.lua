
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

local _window_cache = {}

local function _getWindowName(width, height)
  return width + 10*height
end


local function _createWindow(width, height)
  local canvas = g.newCanvas(width + _MG * 2, height + _MG * 2)
  local polygon = {
    0, 0,
    width - 20, 0,
    width, 20,
    width, height,
    20, height,
    0, height - 20,
  }
  local box
  local hard
  local glow

  g.setCanvas(canvas)
  g.push()
  g.translate(_MG, _MG)

  -- box texture
  g.setColor(16/255, 16/255, 16/255)
  g.setBackgroundColor(0, 0, 0, 0)
  g.setLineWidth(_MG)
  g.polygon("fill", polygon)
  box = g.newImage(canvas:newImageData())
  g.clear()

  -- hard texture
  g.setColor(1, 1, 1)
  g.setLineWidth(4)
  g.polygon("line", polygon)
  hard = g.newImage(canvas:newImageData())
  g.clear()

  -- soft texture
  g.setLineWidth(12)
  g.polygon("line", polygon)
  soft = g.newImage(canvas:newImageData())
  g.clear()

  -- create texture
  g.pop()
  _GAUSSIAN:send("tex_size", {width, height})
  g.setShader(_GAUSSIAN)
  g.draw(box, 0, 0)
  g.setShader()
  g.draw(hard, 0, 0)
  _GAUSSIAN:send("tex_size", {width, height})
  g.setShader(_GAUSSIAN)
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
  return windowname
end

return WINDOW

