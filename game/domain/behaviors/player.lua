
return function (actor)
  -- This returns the action chosen by the user. See gamestate.play and
  -- gamestate.user_turn
  return select(2,coroutine.yield("userTurn", actor))
end
