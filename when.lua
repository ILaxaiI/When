--[[  
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
]]
local when = {}
when.__index = when
when.instance = {}
when.instance.__index = when.instance

--pause/resume a timer instance.
function when.instance:pause()  self.paused = true end
function when.instance:resume()  self.paused = false end

--toggle the timers paused state or set it to a value
function when.instance:toggle(to)
  assert(type(to) == "boolean","got "..type(to).. "Expected Boolean")
  self.paused = to or not self.paused
end

--set wether or not the timer loops
function when.instance:setLoop(bool)
  assert(type(bool) == "boolean","got "..type(bool).. "Expected Boolean")
  self.loop = bool
end


-- remove a timer instance
-- this will swap the timers index with the last element
-- the timer instance will be removed on the next category:update call but its function will not be executed
function when.instance:stop() self.Stop = true end

function when.instance:__tostring()
  return tostring("Timer "..string.format("%.4f",self.time)..", "..self.default)
end


function when.newCategory() return setmetatable({[0] = 0,mode = "loop"},when) end
setmetatable(when,{__call = when.newCategory})


--calling when:new or timer() will create a new timer category
--calling category:new or category() will create a new timer instance in that category
--category:new returns the category as its first argument so timer definitions can be chained, but that way the reference to the timer instance is lost.
  
function when:new(time,loop,func,args,paused)
  self[0] = self[0]+1
  local tmr = setmetatable({time = time,loop = loop,default = time,func = func, args = args,paused = paused or false},when.instance)
  self[self[0]] = tmr
  return self,tmr
end
when.__call = when.new  

local function removetmr(self,id)
  self[id] = self[self[0]]
  self[self[0]] = nil
  self[0] = self[0] - 1
end
local update = {
 loop = function(self,tmr,id)   
  while tmr.time <= 0 do
    tmr.func(tmr.args)
    tmr.time = tmr.time + tmr.default
    tmr.Stop = not tmr.loop
  end
end,

reset = function(self,tmr,id) 
  if tmr.time <= 0 then
    tmr.func(tmr.args)
    tmr.time = tmr.default
    tmr.Stop = not tmr.loop
  end
end
}
-- update a timer category
function when:update(dt)
  for i = self[0],1,-1 do
    local  tmr = self[i]
    if not tmr.paused then
      tmr.time = tmr.time - dt
      if tmr.Stop then
        removetmr(self,i)
      else
        update[self.mode](self,tmr,i)
      end
    end
  end
end
--set wich update mode is used by that category
--loop will call the timer function as multiple times if dt is larger than its time
--reset will call it once and set it the time back to 0

function when:setMode(mode)
  self.mode = assert(update[mode] and mode,'Unexpected timer mode, expected "loop" or "reset"')
end



function when:__tostring()
  local str = "Timer Category with "..self[0].. " entries\n" 
  for i,v in ipairs(self) do
    str = str.."\t"..tostring(v).."\n"
  end
  return str
end


return when
