
return [=[

extern vec2 tex_size;
extern int range = 5;

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

