--
local RUNFLAGS = require 'infra.runflags'

--CONTSTANTS--
local TESTSDIR = "tests/"

--HELPERS--
local filesystem = love.filesystem

--LOCALS--
local _module_name = RUNFLAGS.TEST
local _require_error_msg = [==[

Testing requested, but an error occurred.
Make sure the test file exists in game/test/<test name>.lua
Please specify test to run by running:
>> love game --test=<test name>

If you're running `make`, the command should be:
>> make FLAGS="--test=<test name>"

This error can also have been triggered by
syntax errors in the test file. Please refer
to the error message above for more information.

]==]


--TESTING--
if _module_name then
  local module_path = ("%s%s"):format(TESTSDIR, _module_name)
  local require_success, module_test = pcall(require, module_path)
  if require_success then
    print(("Running test: %s"):format(_module_name))
    local test_successful, err = pcall(module_test)
    assert(test_successful, ("TEST FAILED!\n\n%s"):format(err))
    print("Test Successful!")
  else
    print(module_test)
    print(_require_error_msg)
  end
end

