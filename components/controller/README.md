
# Controller Framework

The Controller Framework is built on the concept of naming convention.

## Naming concept

Inside de Godot Project Setting, if an event is named as "_ui_say_something_" or, for debug events, "_debug_say_something_", an method "_event_say_something_" is called.

The method is called in certain conditions:
- The controller is **enabled**, _set_enabled(true)_
- If the Controller is a Control node then the event is called at __input_event_ loop
- If the Controller is not a Control node the event is processed at __unhandled_input_ loop

After a event is processed the processing loop is cleard to avoid multiple calling between multiple controllers or input loops.


## Default Events

The Controller implements 2 default events:
Event Method              |  Description
--------------------------|--------------------
event_cancel              |  Quit the game
event_toggle_fullscreen   |  Change between fullscreen or window mode
