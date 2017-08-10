
return function (map, actor)
  return function ()
    local i, j = map:randomNeighbor(unpack(map.bodies[actor.body]))
    map:putBody(actor.body, i, j)
    actor:spendTime(3)
  end
end
