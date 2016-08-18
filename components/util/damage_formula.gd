func dice(dcount, dfaces):
  var value = 0
  for i in range(dcount):
    value += 1 + int(rand_range(0, dfaces))
  return value
