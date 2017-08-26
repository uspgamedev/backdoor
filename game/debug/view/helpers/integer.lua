
return function (value, name, range)
  local _, newvalue = imgui.InputInt(name, value, 1, 10)
  if range then
    return math.max(range[1],
                    range[2] and math.min(range[2], newvalue) or newvalue)
  else
    return newvalue
  end
end

