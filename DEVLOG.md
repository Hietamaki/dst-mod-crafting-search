## Dev log

### v.01 - What I've learned
Turns out there is no official documentation, not even API. So the way to learn is to find other mods with similar functionality and using the game scripts as reference.

So far I've found no way to reload specific script, but running c_reset() seems to work as long as there is no error in code, in which case game needs reboot. So the dev experience is a bit laborous. Crash logs can be found in ~/.klei/ (Linux)

Game functions can be run with adding GLOBAL. prefix to functions. Though some don't seem to require it like TheFrontEnd.