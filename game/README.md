
# BACKDOOR ROUTE's source code

This directory contains all the source code for Backdoor Route, organized as
follows:

+ `database/`
  Source and data files regarding the game contents, such as creature types and
  card descriptions.
+ `devmode/`
  Source files for debug and development support in-game.
+ `domain/`
  Source files implementing the rules of gameplay.
+ `gamestates/`
  Source files managing the game interactions between player and gameplay.
+ `helpers/`
  Assorted source files with auxiliary routines.

Besides these, the following directories *should* also be here after the inital
setup but *are not* supposed to be versioned:

+ `cpml/`
+ `lux/`
+ `steaming/`
+ `dkjson.lua`

## Code style

WIP

### Naming conventions

Name capitalization and format should make clear the **role** and **scope** of
the data they label. The conventions we use here are intended to reflect that
principle.

#### Scope-related

1. Any global names should be in `ALL_CAPS`
2. Names local in a source file should start with a `_` (underscore)
  + Unless they are aliases used to name `require`d modules and classes, in
    which case they should be in `ALL_CAPS` or `PascalCase`, respectively.
3. Names local in a function or method have no special markings

#### Role-related

1. Variable names should be in `snake_case`
2. Function and method names should be in `camelCase`
3. Class names should be in `PascalCase`

### Formatting conventions

This is all pretty much arbitrary.

1. Indentation should be two spaces long (NO TABS)
2. Function declaration:
```lua
function foo()
  return 42
end
```
3. When there are too many parameters in a function declaration or call, break
   the line on the last parameter that fits the line and start a new one from
   the opening parenthesis:
```lua
callFunctionWithTooManyParameters(parameter1, parameter2, parameter3,
                                  parameter4, parameter5(didnt_expect_this,
                                                         did_you))
```


