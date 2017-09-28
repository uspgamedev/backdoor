
return function(metainfo)
  local g = love.graphics
  local texture = RES.loadTexture(metainfo.texture)
  local iw, ih = texture:getDimension()
  local frames = {}
  for i, frame in ipairs(metainfo.animation) do
    local qx, qy, qw, qh = unpack(frame.quad)
    frames[i] = {}
    frames[i].quad = g.newQuad(qx, qy, qw, qh, iw, ih)
    frames[i].time = frame.time
    frames[i].offset = frame.offset
  end
end

