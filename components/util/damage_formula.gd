func dice(dcount, dfaces):
  var value = 0
  for i in range(dcount):
    value += int(rand_range(1, dfaces))
  return value
