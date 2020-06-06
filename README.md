# When
Lua library that manages timers
  local when = require("when")
  
  timers are stored in categories,
    local category = when() or when:newCategory() 
   
   to create a timer call
   category(<number> time,<bool> loop, <function> callback, <any> arguments) or category:new("")
 
 then call category:upadte(deltaTime) wherever you need to
