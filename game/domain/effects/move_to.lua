
return function (actor, sector, pos)
  sector:putBody(actor:getBody(), unpack(pos))
end
