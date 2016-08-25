
const STACK_MAX = 16

var stack_ = IntArray()
var starts_ = IntArray()
var top_ = 0

func _init():
  stack_.resize(STACK_MAX)
  starts_.resize(STACK_MAX)

func time_():
  return OS.get_ticks_msec()

func reset():
  for i in range(STACK_MAX):
    stack_[i] = 0
    starts_[i] = 0

func push():
  starts_[top_] = time_()
  top_ += 1

func pop():
  top_ -= 1
  stack_[top_] += time_() - starts_[top_]

func report():
  print("[profiler report]")
  for i in range(STACK_MAX):
    if stack_[i] <= 0:
      break
    printt(i, stack_[i])
