local funcs

function funcs.unset(adjacency)
  for i = 1, 3 do
    adjacency[i] = -1
  end
end

return funcs
