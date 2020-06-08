# When
when is a Lua library that manages timers
```lua
  local when = require("when")
```

timers are stored in categories,
```lua
local category = when() or when:newCategory() 
```
to create a timer and update a categories contents call

```lua
local category, timerInstance = category(<number> time,<bool> loop, <function> callback, <any> arguments) or category:new("")
  --category is returned first so timer creation can be chained
category:update(deltaTime)
```
loop determins wether a timer will be removed after it has been completed

to stop a timer call
```lua
  timerInstance:stop()
  --or timerIsntance.Stop = true
```
this will remove that timer the next time category:update is called without calling its function

you can call
```lua
  category:setMode(<"loop" or "reset">)
```
this determins how a timers in that category handle having timers smaller than dt
reset: the timer gets set to its initial value and only executes its function once,
loop: the timer calls the function as many times as it would have happend during dt
