
return function (actor, sector)
  -- This returns the action chosen by the user. See gamestate.play
  return select(2,coroutine.yield("actorTurn", actor))
end
