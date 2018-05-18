
local _GAUSSIAN_CODE = [=[

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

]=]

local WIDTH = 1280
local HEIGHT = 720

local COLORS = {
  WHITE = {1, 1, 1},
  BLACK = {0, 0, 0},
  DARK = {16/255, 16/255, 16/255},
  NEUTRAL = {0, 0, 0, 0},
  GREEN = {0.1, 0.9, 0.3},
  LIGHT = {0.75, 0.75, 0.75},
  EMPTY = {0.2, .15, 0.05}
}


local QUIT_KEY = {
  escape = true,
  f8 = true,
}

return function ()
  local _fontH1
  local _fontBold
  local _fontText
  local _font_cache = {}

  local _fake_minimap
  local _pixel
  local _gaussian_shader

  function love.load()
    local window = love.window
    local graphics = love.graphics

    -- resolution
    window.setMode(WIDTH, HEIGHT)

    -- fonts
    _font_cache.h1 = {}
    _font_cache.bold = {}
    _font_cache.text = {}
    function _fontH1(size)
      local font = _font_cache.h1[size] if not font then
        font = graphics.setFont("assets/font/Anton.ttf", size)
        _font_cache.h1[size] = font
      end
      graphics.setFont(font)
      return font
    end
    function _fontBold(size)
      local font = _font_cache.h1[size] if not font then
        font = graphics.newFont("assets/font/SairaCondensed-ExtraBold.ttf", size)
        _font_cache.bold[size] = font
      end
      graphics.setFont(font)
      return font
    end
    function _fontText(size)
      local font = _font_cache.h1[size] if not font then
        font = graphics.newFont("assets/font/SairaCondensed-Medium.ttf", size)
        _font_cache.text[size] = font
      end
      graphics.setFont(font)
      return font
    end

    -- textures
    _fake_minimap = graphics.newImage("assets/texture/fakeminimap.png")
    _pixel = graphics.newImage("assets/texture/pixel.png")

    -- shaders
    _gaussian_shader = graphics.newShader(_GAUSSIAN_CODE)
  end

  function love.keypressed(key)
    if QUIT_KEY[key] then
      love.event.quit()
    end
  end

  function love.update(dt)
  end

  function love.draw()
    local graphics = love.graphics

    -- margin & other values
    local mg = 24
    local width = 320
    local length = width-mg*2
    local attr_width = length/4
    local shape = graphics.newMesh({
        {width, 0,
        1, 0},
        {-mg, 0,
        0, 0},
        {-mg, mg+HEIGHT/2,
        0, 1},
        {0, 2*mg+HEIGHT/2,
        0, 0},
        {0, HEIGHT,
        0, 1},
        {width, HEIGHT,
        1, 1},
      }, 'fan', 'dynamic')
    shape:setTexture(_pixel)
    local countour = {
      -mg/2, 0,
      -mg/2, mg/2+HEIGHT/2,
      mg/2, 2*mg-mg/2+HEIGHT/2,
      mg/2, HEIGHT,
    }


    graphics.setBackgroundColor(COLORS.NEUTRAL)
    graphics.setColor(COLORS.WHITE)
    graphics.draw(_fake_minimap, 0, 0, 0,
                  WIDTH/_fake_minimap:getWidth(),
                  960/_fake_minimap:getHeight())
    graphics.push()
    graphics.translate(960, 0)
    --[[-- left
  --]]-- or right?

    -- panel
    graphics.push()
    graphics.setColor(0, 0, 0, 0.2)
    --_gaussian_shader:send("tex_size", {1, 1})
    --graphics.setShader(_gaussian_shader)
    graphics.draw(shape, -8, 0)
    graphics.setColor(COLORS.BLACK)
    graphics.setShader()
    graphics.draw(shape, 0, 0)
    graphics.setColor(COLORS.WHITE)
    graphics.setLineWidth(2)
    graphics.line(countour)
    graphics.translate(8, 0)
    graphics.line(countour)
    graphics.pop()



    -- character name
    _fontBold(24)
    graphics.translate(mg, mg)
    graphics.setColor(COLORS.WHITE)
    graphics.printf("Namer Namington", 0, -8, length, "left")

    -- lifebar
    _fontText(20)
    graphics.translate(0, 48)
    graphics.setColor(COLORS.EMPTY)
    graphics.rectangle("fill", 0, 0, length, 12)
    graphics.setColor(COLORS.GREEN)
    graphics.rectangle("fill", 0, 0, 28/32*length, 12)
    graphics.push()
    graphics.translate(8, -16)
    graphics.setColor(COLORS.DARK)
    graphics.printf("HP 28/032", 0, 0, length-8, "left")
    graphics.translate(-2, -2)
    graphics.setColor(COLORS.WHITE)
    graphics.printf("HP 28/032", 0, 0, length-8, "left")
    graphics.pop()

    -- cooldown bar
    graphics.translate(0, 32)
    graphics.setColor(COLORS.EMPTY)
    graphics.setLineWidth(1)
    graphics.rectangle("fill", 0, 0, length, 12)
    graphics.setColor(COLORS.LIGHT)
    graphics.rectangle("fill", 0, 0, 0.6*length, 12)
    graphics.push()
    graphics.translate(8, -16)
    graphics.setColor(COLORS.DARK)
    graphics.printf("PP 60/100", 0, 0, length-8, "left")
    graphics.translate(-2, -2)
    graphics.setColor(COLORS.WHITE)
    graphics.printf("PP 60/100", 0, 0, length-8, "left")
    graphics.pop()

    -- minimap
    graphics.translate(0, 48)
    graphics.setColor(COLORS.EMPTY)
    graphics.rectangle("fill", 0, 0, length, 192)
    graphics.setColor(COLORS.WHITE)
    graphics.draw(_fake_minimap, 0, 0, 0, length/_fake_minimap:getWidth(), 1)

    -- attributes
    _fontText(24)
    graphics.translate(mg*4/3, 192+2*mg)
    graphics.push()
    graphics.push()
    -- COR
    graphics.setColor(COLORS.WHITE)
    graphics.printf("COR: 5", 0, 0, attr_width, "center")
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.EMPTY)
    graphics.rectangle("fill", 0, 0, attr_width, 16)
    graphics.setColor(COLORS.LIGHT)
    graphics.rectangle("fill", 0, 0, 0.4*attr_width, 16)
    graphics.pop()
    -- ARC
    graphics.translate(attr_width + mg/2, 0)
    graphics.push()
    graphics.setColor(COLORS.WHITE)
    graphics.printf("ARC: 7", 0, 0, attr_width, "center")
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.EMPTY)
    graphics.rectangle("fill", 0, 0, attr_width, 16)
    graphics.setColor(COLORS.LIGHT)
    graphics.rectangle("fill", 0, 0, 0.8*attr_width, 16)
    graphics.pop()
    -- ANI
    graphics.translate(attr_width + mg/2, 0)
    graphics.setColor(COLORS.WHITE)
    graphics.printf("ANI: 3", 0, 0, attr_width, "center")
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.EMPTY)
    graphics.rectangle("fill", 0, 0, attr_width, 16)
    graphics.setColor(COLORS.LIGHT)
    graphics.rectangle("fill", 0, 0, 0.2*attr_width, 16)
    graphics.pop()

    -- PLACEMENTS
    graphics.translate(0, mg*3)
    graphics.setColor(COLORS.WHITE)
    graphics.printf("PLACEMENTS", 0, 0, 128, "left")
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.EMPTY)
    local len = 32
    for i = 1, 6 do
      graphics.rectangle("fill", (i-1)*(len+4), 0, len, len)
    end

    -- TRAITS
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.WHITE)
    graphics.printf("TRAITS", 0, 0, 128, "left")
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.EMPTY)
    local len = 32
    for i = 1, 6 do
      graphics.rectangle("fill", (i-1)*(len+4), 0, len, len)
    end

    -- CONDITIONS
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.WHITE)
    graphics.printf("CONDITIONS", 0, 0, 128, "left")
    graphics.translate(0, mg*1.5)
    graphics.setColor(COLORS.EMPTY)
    local len = 32
    for i = 1, 6 do
      graphics.rectangle("fill", (i-1)*(len+4), 0, len, len)
    end

    graphics.pop()
  end

  love.load()
end
